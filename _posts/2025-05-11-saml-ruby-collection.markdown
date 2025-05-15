---
title: "SAML and Ruby: The Collection"
categories:
  - ruby
  - rails
  - sso
  - saml
excerpt: "My colleagues and I have learnt a lot about supporting SAML in our Rails app. I've collected a lot of that into a handful of posts."
---

Over the past year, my colleagues and I at [Covidence](https://www.covidence.org) have been rolling out SSO support for our Rails application - using SAML in particular. This has prompted a great deal of learning, as well as finding some neat solutions to a few challenges - so I've written up a handful of posts to share both some general concepts, and some of our solutions.

* [Terminology](/2025/05/05/saml-ruby-terminology.html)
* [Building a service provider](/2025/05/06/saml-ruby-service-provider.html)
* [Parsing SAML federation data](/2025/05/07/saml-ruby-federations.html)
* [Testing with ephemeral (PR) apps](/2025/05/08/saml-ruby-bridging.html)
* [Request and feature tests](/2025/05/09/saml-ruby-automated-tests.html)
* [A local IdP for development environments](/2025/05/10/saml-ruby-development-idp.html)

A lot of the content from these posts were first shared as a talk at the Melbourne Ruby Meet in October 2024 (and then again at Ruby Retreat NZ in May 2025). If taking in information via video is preferred, [you can watch that here](https://www.youtube.com/watch?v=MeQXR8ojX5c):

<iframe width="560" height="315" src="https://www.youtube.com/embed/MeQXR8ojX5c?si=FNKy3Ly8zMT4tTSo" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
