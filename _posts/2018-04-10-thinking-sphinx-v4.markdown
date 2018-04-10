---
title: "Thinking Sphinx v4"
categories:
  - ruby
  - search
  - sphinx
  - thinking sphinx
  - rails
excerpt: "Thinking Sphinx v4 and some milestone reflections"
---

Thinking Sphinx v4 has just been released. This feature is an evolution on the 3.x releases - there are a few new significant features (support for merging indices and UNIX sockets in particular), and it supports the brand new Rails 5.2. The release notes cover [all of this](https://github.com/pat/thinking-sphinx/releases/tag/v4.0.0) in more detail.

The changes also allow overriding the core rake tasks, and so combined with the latest release of the `flying-sphinx` gem (v2.0.0), all standard tasks operate as they should no matter whether they're on a machine you host, or on Heroku via [the Flying Sphinx add-on](https://elements.heroku.com/addons/flying_sphinx).

This is _so_ much neater than different index types or `flying-sphinx` having their own set of commands, and I should have taken this approach from the very beginning. Now: to process your indices, just run `rake ts:index`, and you'll get the appropriate behaviour no matter what. The same for `ts:start` and `ts:stop` and `ts:rebuild` and so on.

Another recent change (in v3.4.0) changed the real-time indices to use the original tasks, so `ts:index` and `ts:rebuild` are the consistent approaches to reach for.

---

One other thing to note is that Thinking Sphinx marked its 10th birthday back in September last year:

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">Today (as far as I can tell) marks 10 years of Thinking Sphinx - my most successful open source project 🎂🎈🎉</p>&mdash; Pat Allan (@pat) <a href="https://twitter.com/pat/status/906058024825085953?ref_src=twsrc%5Etfw">September 8, 2017</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

It's been quite the adventure, and I'm very lucky to have had such a great adoption of this library over the past decade. It's not nearly as popular as it used to be, but that's fine - I'm still happy to keep it working with modern Rails versions and add in occasional new features.

Writing this gem has also led to countless opportunities of work and travel, and connected me to so many lovely Rubyists around the world. Thank you so much to everyone who's submitted bug reports and patches, or used TS at some point in a project new or old.
