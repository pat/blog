---
title: "SAML and Ruby: Automated request and feature tests"
categories:
  - ruby
  - rails
  - sso
  - saml
excerpt: "Writing tests to confirm SAML authentication in Ruby isn't too daunting at a request level - but full feature tests are also possible!"
---

*This post is part of the broader series around [SAML and Ruby](/2025/05/11/saml-ruby-collection.html).*

When we started building out SAML support at [Covidence](https://www.covidence.org), we looked around for examples of how to best write automated tests and didn't find anything particularly compelling. Ideally, we wanted feature tests - the full flow of starting a sign-in process on our site, via an identity provider, and then having an active session - but a path through wasn't clear.

So instead, we turned to request specs, and found that worked quite well! Our testing framework of choice is RSpec, but I'm sure these tests could be adapted to other tools.

Taking in the approach outlined in [this post](/2025/05/06/saml-ruby-service-provider.html) for the controller actions, we can test the endpoint which initiates a SAML request (the <code>new</code> action), where we confirm that the resulting redirect:

* Has a `SAMLRequest` parameter
* Has a `RelayState` parameter
* And is going to the correct IdP URL

```ruby
get "/sign_in/saml"
expect(response.status).to eq 302

redirect_uri = URI.parse(response.location)
queries = CGI.parse(redirect_uri.query)

# Confirm a SAMLRequest parameter is sent:
expect(queries["SAMLRequest"].length).to eq(1)
# Confirm a RelayState parameter is sent
# (perhaps with your preferred data):
expect(queries["RelayState"].length).to eq(1)

# Confirm we're redirecting to the IdP's SSO Service URL:
redirect_uri_without_query = redirect_uri.dup.tap {
  |uri| uri.query = nil
}.to_s
expect(redirect_uri_without_query).to eq(idp_sso_service_url)
```

Testing the receiving of a SAML response (the <code>create</code> action) is a bit trickier.

A reasonable approach is to stub out the response object - you don't really care how the SAML response parameter is constructed, you're just checking what happens when a valid response is passed in.

The end result of what the endpoint should do is up to you and your application. Maybe it's just a redirect (as per below), maybe it's reviewing certain cookies, or even parsing the session cookie to confirm its state.

```ruby
saml_response = instance_double(
  "OneLogin::RubySaml::Response",
  is_valid?: true,
  name_id: "test@example.com",
  name_id_format: "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
)

allow(OneLogin::RubySaml::Response)
  .to receive(:new)
  .and_return(saml_response_double)

post "/sign_in/saml",
  params: {
    RelayState: relay_state,
    SAMLResponse: "saml_reponse_string"
  }

expect(response).to redirect_to(logged_in_path)
```

These request tests have served us well - we've fleshed them out with more examples specific to our application: how failures are handled, how different customer states are managed, etc.

But the holy grail of a full feature test was still there, tempting us.

And we had a realisation, inspired by our work of managing requests from an IdP perspective with [our bridging logic](/2025/05/08/saml-ruby-bridging.html): what if we have our own tiny IdP server, running as a side service within our test suite? This removes any need to have an external service involved, keeping things controllable and reliable. (After all, you shouldn't test what you can't control!)

So we built a mini Rack app that operated in a separate thread, and it's worked well. So well, in fact, that we've just extracted it out into a gem for others to use: [ssolo](https://github.com/covidence/ssolo)!

It's a bit more involved, so let's break down the setup. Firstly, you'll want to create a new ssolo controller to manage the service. When you start it, you'll need to provide both the certificate for your service provider, and a `name_id` value. This value will be immediately returned by the IdP (rather than prompting the user for credentials).

```ruby
controller = SSOlo::Controller.new
controller.start(
  sp_certificate: <<~CERT,
    -----BEGIN CERTIFICATE-----
    ...
    -----END CERTIFICATE-----
  CERT
  name_id: "test@example.com"
)
```

Then, you can use that controller to access the IdP's settings to configure your SAML requests appropriately:

```ruby
# connect up the appropriate SAML settings via an
# OneLogin::RubySaml::Settings instance:
controller.settings #=> OneLogin::RubySaml::Settings
controller.settings.idp_entity_id
controller.settings.idp_sso_service_url
controller.settings.idp_cert

# These details are also available via a URL:
controller.metadata_url
```

The core piece, though, is actually writing your tests to use this IdP.

```ruby
# Click something that takes you off to the IdP:
click_on "Sign in via SSO"

# And then it immediately redirects you back, using the
# previously specified name_id:
expect(page).to have_content("test@example.com")
```

Once you're done, make sure you then shut the IdP process down:

```ruby
controller.stop
```

We hope it's useful for others - please do give it a spin if you're testing SAML in your own apps! And of course, questions and contributions are welcome via [the ssolo GitHub repo](https://github.com/covidence/ssolo).

Oh, and maybe you want to use ssolo for your development environment too? [Onwards to the next post](/2025/05/10/saml-ruby-development-idp.html)!
