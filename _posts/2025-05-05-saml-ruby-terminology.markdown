---
title: "SAML and Ruby: The Terminology"
categories:
  - ruby
  - rails
  - sso
  - saml
excerpt: "..."
---

*This post is part of the broader series around [SAML and Ruby](/2025/05/11/saml-ruby-collection.html).*

When working on SSO, there's a lot of terminology that crops up, and it can get rather overwhelming at times, especially when you're new to it all. Here's a rough and ready list of common terms that you may come across.

### SSO

SSO stands for "Single Sign-On", which is the process of delegating authentication to a third-party service.

You've likely come across it at some point - you're viewing a website, you need to sign in, and it gives you the option of authenticating via a _different site_ such as Google or Facebook or (once upon a time) Twitter. You click the link, you're taken to that third-party site to sign in, and then you're sent back to the original site and you've been logged in there too.

That process? That's SSO.

### Authentication vs Authorisation

_Authentication_ is the process of confirming who someone is. Commonly, this is done via a username and password.

_Authorisation_, however, is checking whether someone has access to do certain things.

For example: there's a distinction between being logged into a site (authentication), and having administrator access to manage others' accounts (authorisation).

### SAML

SAML is a standardised protocol for SSO. It's a particular way of going about asking a third party who a person is.

There are other SSO protocols you may have heard of. OAuth is quite common. OIDC is another. I'm sure there's more, but thankfully I've not had to deal with them.

This series of posts are focused on SAML, though some of the concepts I'm sure apply more broadly.

### Identity Providers (IdPs)

When it comes to the back and forth between sites, we have **identity providers**, or IdPs. These are the services which confirm the identity of the user - i.e. where a password is entered. A very common example when you sign in to a site via Google: Google is the IdP.

### Service Providers (SPs)

On the other side of fence is the Service Provider, or SP. This is the site that directs you off to the IdP - the one that has the button that says "Sign in with Google" or similar, and handles the response from the IdP when an identity has been confirmed.
