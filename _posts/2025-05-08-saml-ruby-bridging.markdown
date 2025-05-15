---
title: "SAML and Ruby: Testing with ephemeral apps"
categories:
  - ruby
  - rails
  - sso
  - saml
excerpt: "Identity providers require specific domains for testing - which is a challenge for preview/PR applications. We've found a way through this by building a bridging mechanism into our staging site."
---

*This post is part of the broader series around [SAML and Ruby](/2025/05/11/saml-ruby-collection.html).*

When it comes to testing our work manually (alongside our automated test suite), we make use of Heroku's preview apps linked to GitHub pull requests.

And largely, that works well for us - but when it comes to testing our SAML integration, we've hit a challenge: identity providers (IdPs) require service providers to be accessed by a fixed route, but our preview apps are on a range of subdomains.

For example: a production site may be available at `app.example.com`, and the staging site at `staging.example.com`. But each preview app will be at `preview-1.example.com`, `preview-2.example.com`, and so on - the domains are constantly changing.

The IdPs we've been testing with are resolute about the endpoints being fixed - the domain and the path. Patterns are not allowed either. And they're an external service, not something we can control… so, we were feeling a bit stuck!

Then, a moment of realisation: let's build something we _can_ control - and this has ended up being a SAML bridging service via our staging site.

* The preview app initiates a SAML request and sends it to the staging site (operating as an IdP).
* The staging site then starts a second SAML request, forwarding the user onto the true IdP.
* The IdP verifies the user and sends them back to the staging site (operating as a service provider), finishing the second SAML flow.
* The staging site then immediately passes the identity through to the preview app, to finish the initial SAML flow.

Using our staging site means we don't have to deploy a whole other app elsewhere - though we of course make sure this functionality is _not_ available in production.

From a Rails perspective, we've done this in a new controller, with a pair of actions (again <code>new</code> and <code>create</code>, just like in [our main SAML controller](/2025/05/06/saml-ruby-service-provider.html)).

```ruby
def new
  # Save original request details
  save_identity_cache

  redirect_to(
    OneLogin::RubySaml::Authrequest.new.create(
      # Settings for the actual IdP:
      service_settings,
      # The original request's ID:
      RelayState: identity_request.request_id
    )
  )
end

private

# The details of the initial SAML request (sent from the preview
# site to the staging site).
def identity_request
  @identity_request ||= SamlIdp::Request.from_deflated_request(
    params[:SAMLRequest]
  )
end

# And save those initial details to the cache, to re-use on the
# return journey:
def save_identity_cache
  Rails.cache.write(
    identity_request.request_id,
    {
      relay_state: params[:RelayState],
      issuer: identity_request.issuer,
      acs_url: identity_request.acs_url
    }
  )
end
```

This <code>new</code> action is the endpoint on our staging site that accepts the original SAML request, and initiates a _new_ SAML request to the 'true' identity provider.

As part of this, it saves the essential details from the original request in the Rails cache and uses the RelayState in the _new_ request to keep that identifier. Using a cache here rather than a session is important, as session cookies are not passed along when you're redirecting between sites.

And then, we need to handle the request coming back from the true identity provider:

```ruby
def create
  @identity_acs_url = identity_cache[:acs_url]
  @identity_relay_state = identity_cache[:relay_state]

  # `encode_response` comes from the saml_idp gem
  @identity_response = encode_response(
    service_response,
    audience_uri: identity_cache[:issuer],
    acs_url: identity_cache[:acs_url],
    encryption: {
      # Both SP and IdP have certificates. This should
      # be the certificate for the original service provider
      # (i.e. the preview site).
      #
      # An instance of OpenSSL::X509::Certificate is expected
      cert: saml_certificate,
      block_encryption: "aes256-cbc",
      key_transport: "rsa-oaep-mgf1p"
    }
  )
end

private

def identity_cache
  @identity_cache ||= Rails.cache.read(identity_cache_key)
end

def identity_cache_key
  params[:SAMLRequest] ? identity_request.request_id : params[:RelayState]
end

def service_response
  @service_response ||= OneLogin::RubySaml::Response.new(
    params[:SAMLResponse],
    settings: service_settings
  ).tap do |response|
    unless response.is_valid?
      raise ArgumentError, response.errors.join(",")
    end
  end
end
```

And the corresponding view:

```html
<%= form_tag(@identity_acs_url, style: "visibility: hidden") do %>
  <%= hidden_field_tag("SAMLResponse", @identity_response) %>
  <%= hidden_field_tag("RelayState", @identity_relay_state) %>
  <%= submit_tag "Submit" %>
<% end %>

<script type="text/javascript">
  document.forms[0].submit();
</script>
```

We need to render a form that automatically submits, because SAML responses are sent via POST requests - so we can't rely on a standard HTTP redirect, which is sent as a GET.

For this action, we're making use of [the saml_idp gem](https://github.com/saml-idp/saml_idp), which we configure as follows:

```ruby
# config/initializers/saml_idp.rb
SamlIdp.configure do |config|
  config.base_saml_location = "https://staging.example.com/saml"
  # This is the certificate and private key for the staging site when
  # operating as an IdP.
  config.x509_certificate = saml_certificate.to_pem
  config.secret_key = saml_private_key.private_to_pem
  config.algorithm = :sha256
  # This block defines how we convert a 'principal' object to a name_id.
  # In our case, the principal is already a SAML response, so we can
  # just extract the name_id directly from it.
  config.name_id.formats = {
    email_address: ->(principal) { principal.name_id }
  }
end
```

You may have noted in the code samples above that there's a couple of references to certificates and private keys. These certificates are ones you can generate yourself, and this can be done within Ruby code:

```ruby
name = OpenSSL::X509::Name.parse "/CN=nobody/DC=example"
private_key = OpenSSL::PKey::RSA.new 2048

certificate = OpenSSL::X509::Certificate.new
certificate.version = 2
certificate.serial = 0
certificate.not_before = Time.now
certificate.not_after = Time.now + (10 * 365 * 24 * 60 * 60)
certificate.public_key = private_key.public_key
certificate.subject = name
certificate.issuer = name
certificate.sign(private_key, OpenSSL::Digest.new("SHA256"))

certificate
```

There are distinct certificates for the preview sites acting as service providers, the staging site acting as an identity provider, and the staging site acting as a service provider. It's easy to get tripped up when attempting to use the right certificate in the right moment - so you may want to use a single certificate for all of these scenarios, given this is for internal testing.
