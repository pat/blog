---
title: "SAML and Ruby: Building a Service Provider"
categories:
  - ruby
  - rails
  - sso
  - saml
excerpt: "Building SAML service provider logic in a Rails app isn't actually as daunting as I first feared."
---

*This post is part of the broader series around [SAML and Ruby](/2025/05/11/saml-ruby-collection.html).*

If you're building a Rails site that needs to act as a SAML service provider, you've got two key options: you can use a third party service to manage the integration with identity providers, or you can build out the logic yourself.

There are a great many third party services to consider, including Auth0, Shibboleth, Firebase, Kinde, KeyCloak, and FusionAuth. Some of these are closed-source paid services, others are open source - often with a paid option for managed hosting. There's value in these options, so you may want to investigate further.

However, building support directly in your Ruby or Rails app isn't actually as daunting as I first feared - and as a bonus, it lets you retain control of the customer/user data, rather than being beholden to the limitations and terms of a separate service.

### ruby-saml and Osso

The two key things that greatly helped us with building out service provider support into our app at Covidence are:

* The [ruby-saml gem](https://github.com/SAML-Toolkits/ruby-saml), which has existed for many years, and so has been extensively tested against a wide variety of identity providers;
* And [a blog post by Osso](https://dev.to/sammybauch/add-saml-sso-to-a-rails-6-app-20ld) on how to use that gem in a Rails application.

Osso was once a third party option, and while they don't exist as a business any more, I'm very glad for their generous spirit in sharing a solid starting point for Ruby developers diving into SAML. You'll be well-served by reading their post, but in case a shorter summary is useful, here's our take.

### The way out

There are two key endpoints required to behave as a SAML service provider: one that redirects your visitors out to the identity provider, and one that accepts the resulting response when they're sent back to your site with a verified identity.

For me, these work well as <code>new<code> and <code>create</code> actions in a single controller. Let's take them one at a time.

```ruby
class SAMLController < ApplicationController
  def new
    # Generate a new SAML request
    saml_request = OneLogin::RubySaml::Authrequest.new

    # Send the current visitor away to the IdP:
    redirect_to(
      saml_request.create(
        # These are settings for the specific IdP:
        saml_settings,
        # This is your own context/state, which the IdP does not
        # care about but it will send it back to you:
        RelayState: "new-user-request"
      ),
      # Ensure Rails is okay with you redirecting people away to
      # a different site:
      allow_other_host: true
    )
  end
end
```

In this action, we're generating a new SAML request, and then using it to build a redirect URL for a specific identity provider (the `saml_settings` method) and our own app's context or state (the `RelayState` parameter). Relay states will be sent back to us by the IdP - the value of it is entirely up to you, but should be a maximum of 80 bytes. The IdP will not parse it, so it's purely for your own app's use.

The `saml_settings` method could look something like the following:

```ruby
def saml_settings
  settings = OneLogin::RubySaml::Settings.new

  # Where the IdP sends users back to on our site:
  settings.assertion_consumer_service_url =
    "http://#{request.host}/saml_sessions"

  # A unique identifier of our service, sometimes requested by
  # the IdP:
  settings.sp_entity_id =
    "http://#{request.host}/saml/metadata"

  # A unique identifier of the IdP:
  settings.idp_entity_id =
    "https://google.com/..."

  # The IdP URL our `new` action redirects users to:
  settings.idp_sso_service_url =
    "https://google.com/saml/..."

  # The X.509 certificate used to sign requests for the IdP:
  settings.idp_cert = <<~CERT
    -----BEGIN CERTIFICATE-----
    ...
    -----END CERTIFICATE-----
  CERT

  settings
end
```

This method is generating an object that contains all the relevant details for interacting with a given identity provider. The examples in the code are referring to Google, but you'll want to update it for the IdP you're actually talking to.

* `assertion_consumer_service_url` is a URL is where visitors will be redirected back to on a successful authentication. This should point to the <code>create</code> action in this controller we're working on.
* `sp_entity_id` is an identifier for your service, and should be unique from the perspective of the identity provider.
* `idp_entity_id` is an identifier for the identity provider, supplied by them, and should also be considered unique.
* `idp_sso_service_url` is supplied by the identity provider, and is a live URL where we redirect visitors to.
* `idp_cert` is a X509 certificate supplied by the identity provider, used for signing requests.

The entity IDs for both service providers and identity providers are usually URLs. This is not a hard requirement for the SAML specification, but seems to have become a de-facto standard.

These URLs don't need to be functional - it doesn't matter if they return a 404 - but it is recommended that they return SAML metadata outlining the provider's details as an XML document (though this is beyond the scope of this post).

There are other settings that your IdP may require - these can be specified as per [the ruby-saml documentation](https://github.com/SAML-Toolkits/ruby-saml?tab=readme-ov-file#the-initialization-phase), or parsed via their XML metadata document:

```ruby
parser = OneLogin::RubySaml::IdpMetadataParser.new
settings = parser.parse_remote("https://example.com/idp/metadata")
```

It is _very strongly_ recommended that these settings are cached regularly, rather than requested for every new SAML request, so your site isn't beholden to Internet connectivity glitches or failures on the IdP site.

### The way back in

The above <code>new</code> action sends visitors off to the IdP - but then you'll want an endpoint for their return. It could look something like the following:

```ruby
class SAMLController < Application Controller
  # Disable CSRF checks for our create action:
  skip_before_action(
    :verify_authenticity_token, only: [:create]
  )

  def new
    # ... as above
  end

  def create
    # Parse the given SAML response
    saml_response = OneLogin::RubySaml::Response.new(
      params[:SAMLResponse]
    )
    # And apply the same IdP configuration settings
    saml_response.settings = saml_settings

    # If it's a valid response, then we have a confirmed identity
    # and can log the visitor in:
    if saml_response.is_valid?
      session[:userid] = saml_response.nameid
    else
      # Otherwise, the response is invalid - you'll probably want
      # to provide some feedback and ask people to try logging in
      # again.
      # ...
    end
  end

  private

  def saml_settings
    # ... as above
  end
end
```

When the HTTP request comes in, we want to verify the SAML response with the same IdP settings as before. If the SAML response is valid, then we know we have a confirmed identity, and can use that to log them into our site.

The supplied `nameid` (or `name_id`) from the IdP might be an email address, or a persistent unique identifier for the user/identity, or even a more ephemeral reference. It varies for each identity provider, and sometimes can be configured - so it's best to ensure you know ahead of time what you're dealing with here. If you need to handle a variety of name IDs, then looking at `saml_response.name_id_format` could be helpful.

As for the logic of actually logging someone into your site with this identity - well, that's going to depend on how you've implemented authentication, whether it's via [Devise](https://github.com/heartcombo/devise) or [Clearance](https://github.com/thoughtbot/clearance) or another gem, or something you're rolling yourself. At this point, the SAML flow is complete, so the rest is up to you.

But perhaps you want to read some of the [other posts](/2025/05/11/saml-ruby-collection.html), to get a sense of how to test all of this!
