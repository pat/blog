---
title: "Friendly Frozen String Literals"
date: 2017-07-27 11:00:00
categories:
  - ruby
  - rails
  - programming
  - strings
---

(If you're not entirely familiar with the terms frozen, string, or literal - especially in relation to Ruby - it's probably best starting with [the previous post](an-introduction-to-frozen-string-literals.html) which introduces these concepts.)

Since the 2.3.0 release of Ruby, there's been the optional feature to make all string literals frozen. This means that any string literal within your code is frozen and cannot be modified. As an added bonus, identical string literals in multiple locations are the same object (and for what it's worth, this is how symbols already behave), so the memory profile of your app is potentially reduced.

If you were doing something like the following in a web app on every request:

    response.headers["Content-Type"] = "application/json"

In Ruby normally, every single request would create two new strings in memory: `"Content-Type"` and `"application/json"`. With this feature enabled, only two strings would be created ever (well, within the context of this example) - one for each distinct value - and they'd be referred to for each request.

Put all of this together, and the overall advantage of this feature is reduced memory usage, with the added benefit of avoiding potentially unexpected string modifications.

## Enabling it in a single file

If you want to enable this feature on a per-file basis, you can use a pragma comment at the very top of a file to tell Ruby that all string literals in a given file should be frozen:

    # frozen_string_literal: true
    class Foo
      # ...
    end

A pragma comment is an instruction for Ruby that when reading the file, it should treat it a certain way. They only impact that specific file, not any other files that it in turn loads.

## Enabling it for every file

If, however, you want this feature to apply to all Ruby files loaded in a given process, you can use the `RUBYOPT` environment variable:

    RUBYOPT="--enable-frozen-string-literal" bundle exec foo

It doesn't matter whether you're loading your own code, third-party gems, or even the standard library - the feature will be enabled for all string literals in _all_ files... and this may cause some problems, because there's a lot of code out there that isn't frozen-string-literal friendly.

## The Ecosystem

Free performance improvements are always welcome - but in this case there's a catch. Many gems out there aren't written in ways that treat string literals as frozen by default, so the feature cannot be enabled as a global default. There are efforts underway to change this, though!

(These lists are by no means exhaustive, but rather are a signal to show the progress in the Ruby community - even when some of the gems are mine.)

### Gems with Frozen-String-Literal Friendly Releases

* bundler
* nokogiri
* test-unit
* gettext
* syntax
* riddle (mine)
* sliver (mine)
* combustion (mine)
* sprockets (pre-release)
* aruba (pre-release)

### Gems with Frozen-String-Literal Friendly Commits

At the time of writing, these gems all have patches that cover frozen string literals that will be part of their upcoming releases.

* rspec
* devise
* redis
* simplecov and simplecov-html
* coderay
* thinking-sphinx (mine)

### Gems with Frozen-String-Literal Friendly Pull Requests

* [builder](https://github.com/tenderlove/builder/pull/6)
* [rack](https://github.com/rack/rack/pull/1182)
* [thor](https://github.com/erikhuda/thor/pull/567)
* [puma](https://github.com/puma/puma/pull/1376)
* [addressable](https://github.com/sporkmonger/addressable/pull/260)
* [cucumber](https://github.com/cucumber/cucumber-ruby/pull/1136)
* [parser](https://github.com/whitequark/parser/pull/354) (used by rubocop)
* [racc](https://github.com/tenderlove/racc/pull/80) (used by parser)
* [sass](https://github.com/sass/sass/pull/2352)
* [websocket](https://github.com/imanel/websocket-ruby/pull/30)

### Rails

Rails isn't quite there yet, but there has been ongoing work by [Kir Shatrov](https://github.com/kirs) and myself and likely others on this, supported by the Rails core team.

Some parts of Rails are now frozen-string-literal friendly (including ActiveSupport, ActiveModel, ActiveRecord and ActiveJob), but this is all happening in the `master` branch - so I'm expecting it to be part of Rails v5.2, which could be a while away.

## Updating Behaviour

While I've been working on improving my own code and offering patches to gems, I've found that the incompatible code is generally appending further strings to a string literal. Something along the lines of:

    buffer = ""
    buffer << "My name is "
    buffer << first_name
    buffer << " " << last_name unless last_name.nil?
    buffer

In this example, there are a few string literals, but it's only the first one that is problematic, because it's the one being modified.

One approach is to change the `<<` calls to `+=`:

    buffer = ""
    buffer += "My name is "
    buffer += first_name
    buffer += " " << last_name unless last_name.nil?
    buffer

However, if you use `+=` you're creating a new string on every call, and thus losing the advantage of the memory benefits of a single string. It's much better to instead create a mutable copy of the initial string via the `dup` method:

    buffer = "".dup
    buffer += "My name is "
    buffer += first_name
    buffer += " " << last_name unless last_name.nil?
    buffer

`dup` copies everything about an object in Ruby except for its frozen state, so it provides exactly what we need. Another equally viable approach is to use `String.new`:

    buffer = String.new ""
    buffer += "My name is "
    buffer += first_name
    buffer += " " << last_name unless last_name.nil?
    buffer

In both of these cases, the new strings are computed values, rather than literals, and they are mutable, so it's more a matter of personal preference of what style you like more.

One caveat to note with `String.new` is that if you call it without any arguments, you do get an empty (and mutable) string, but it will always have an encoding of ASCII-8BIT. If an argument is passed, the new string will respect the encoding of the first argument - which is likely to be Ruby's default of UTF-8.

## Enforcing Behaviour

Beyond the actual usage changes, it's probably worth adding in the pragma comment across all of your files. That may initially seem like hard work, but you can enforce this [via RuboCop](http://rubocop.readthedocs.io/en/latest/cops_style/#stylefrozenstringliteralcomment), and add them to existing projects with [pragmater](https://github.com/bkuhlmann/pragmater).

If you're lucky enough to have a situation where all of your dependencies are frozen-string-literal friendly, then you can just use the `RUBYOPT` environment variable. Don't forget to add that to your CI service as well to avoid any regression issues in your test suite.

## Moving Forward

I'm no benchmarking expert, but some quick tests locally have suggested that using frozen string literals does make code using a lot of literals a bit faster.

It's also worth noting that this is an experimental feature of Ruby - and may become the default in Ruby v3 - so I'd expect performance to improve further, especially as the broader Ruby ecosystem adapts to take advantage of this. Thus: the more frozen-string-literal friendly code we have, the better!
