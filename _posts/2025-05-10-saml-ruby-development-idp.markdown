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

Most of the big pain points that have cropped up regularly for us at [Covidence](https://www.covidence.org) while building out support for SAML requests in our app were related to testing.

**Manual testing in preview environments** is something we've managed via [bridging SAML requests through our staging server](/2025/05/08/saml-ruby-bridging.html) through to a legitimate (production) identity provider.

**Automated testing** is something we've figured out through both [request and feature tests](/2025/05/09/saml-ruby-automated-tests.html), particularly aided by a micro IdP service which we've wrapped up into the open source gem [ssolo](https://github.com/covidence/ssolo).

But **manual testing in local environments** is something we've mucked around with in various ways without finding something ideal... well, until we built `ssolo`. Because if a micro IdP can be running as a server for our tests, surely it can also be running as a server for our development environments too?

(Yes, yes it can)

The gem documentation does cover this, but let's run through it here as well! Essentially, once you have the gem installed, you can fire it up alongside a set of environment variables:

```sh
bundle exec ssolo \
  SSOLO_PERSISTENCE=~/.ssolo.json \
  SSOLO_SP_CERTIFICATE="-----BEGIN CERTIFICATE-----\n...\n-----END CERTIFICATE-----" \
  SSOLO_HOST=127.0.0.1 \
  SSOLO_PORT=9292 \
  SSOLO_SILENT=true
```

`SSOLO_PERSISTENCE` is important - this tells ssolo where to save the generated private key and certificate. While in tests it's (hopefully) fine for those values to change regularly, in our local environment we want these settings to stick around - they're likely being cached somewhere.

`SSOLO_SP_CERTIFICATE` is also important - this is the service provider certificate that your local app is using for its SAML requests. The IdP server needs to know this, so it can both read the requests and send appropriately signed responses back.

`SSOLO_HOST` and `SOLO_PORT` are optional - these are the underlying Puma defaults, but you can customise them if needed.

And `SSOLO_SILENT` can hide the logging if that's what you'd prefer. This is more useful in a test environment - in development situations, you probably want to know if something's gone pear-shaped!

You can _also_ specify `SSOLO_NAME_ID` to keep the supplied name ID as a fixed value. But otherwise, you will be prompted for a value when you're going through the SAML flow.

Wrap this command up into your own script, or in a Procfile, so it's easy to have running whenever you need it.

---

And once you've got it there and running, there's two endpoints to be mindful of:

* `GET /metadata` which returns the XML metadata
* `GET /saml` which is the URL to initiate SAML requests

So, if you're running the server with the default environment variables, you should be able to see the metadata via [http://127.0.0.1:9292/metadata](http://127.0.0.1:9292/metadata), and make SAML requests to [http://127.0.0.1:9292/saml](http://127.0.0.1:9292/saml).

With all of this in place, you should be able to initiate a SAML request to this ssolo IdP, and quickly get a response back with your preferred name_id. No extra credentials required, no server wrangling with external third parties.

One last note: please keep in mind that `ssolo` is very minimal - we've built it out to be just enough for us. If you find some rough edges, we'd love to hear about them via [the GitHub repo](https://github.com/covidence/ssolo) - and pull requests are of course welcome too!
