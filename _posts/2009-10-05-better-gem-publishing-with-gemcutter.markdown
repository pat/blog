---
title: "Better Gem Publishing with Gemcutter"
redirect_from: "/posts/better_gem_publishing_with_gemcutter/"
categories:
  - gemcutter
  - gems
  - ruby
---
If you’re working with Ruby and have been paying attention to Twitter or
RSS feeds, then you’ve probably heard of
[Gemcutter](http://gemcutter.org). If not, it’s the latest flavour for
publishing gems, and I’m finding the simplicity of it a delight.

Its appearance is doubly useful, as since [GitHub](http://github.com)
has moved to Rackspace, automated gem building from projects has [been
disabled](http://github.com/blog/506-state-of-the-hub-rackspace-day-2),
perhaps never to return.

### Getting Started

If you’ve not clicked the link to Gemcutter yet, let’s run down how easy
it is to get it set up on your machine.

    sudo gem install gemcutter
    gem tumble

That’s it. Any future gem installs will look at Gemcutter’s growing
library.

This doesn’t replace [RubyForge](http://rubyforge.org/) or
[GitHub](http://gems.github.com/) in your sources list, but it does set
Gemcutter as the top priority - which is fine, as it has almost all of
RubyForge’s gems ready for you anyway.

### Publishing

Firstly, [get yourself an account](http://gemcutter.org/sign_up), click
that confirmation email link, then hunt down a gem you want to publish,
and run the following command:

    gem push my-awesome-gem-0.0.1.gem

If it’s your first time, you’ll be asked for your login details, and
then the gem is online and ready for anyone to download it. No waiting,
no forms, no pain.

When you’ve got a new version, just run that same command again,
pointing to the new gem file:

    gem push my-awesome-gem-0.1.0.gem

One command. No authentication prompts. Available for everyone straight
away. Awesome.

### Migrating

If you’ve already got gems on RubyForge that you’d like to take
ownership of on Gemcutter, it’s another one-step process:

    gem migrate my-legacy-gem

You’ll be prompted for your RubyForge account name and password, and
then Gemcutter does the rest.

Pretty easy, hey?

### My Gems

Over this past weekend, I made Gemcutter the definitive source for all
of my gems:

-   [Thinking Sphinx](http://gemcutter.org/gems/thinking-sphinx)
-   [Thinking Sphinx for Sphinx
    0.9.9](http://gemcutter.org/gems/thinking-sphinx-099)
-   [Thinking Sphinx/Raspell
    plugin](http://gemcutter.org/gems/thinking-sphinx-raspell)
-   [Riddle](http://gemcutter.org/gems/riddle)
-   [Ginger](http://gemcutter.org/gems/ginger)
-   [Fakeweb Matcher](http://gemcutter.org/gems/fakeweb-matcher)
-   [Postie](http://gemcutter.org/gems/postie)

### Incoming Confusion

There’s been some discussion about whether Gemcutter should replace the
gem hosting facilities provided by Rubyforge. This may or may not
happen, but it is confirmed that Gemcutter will be moving to
[rubygems.org](http://rubygems.org) soon.

Everything will still work fine via the
[gemcutter.org](http://gemcutter.org) address, though, so don’t let that
hold you back from diving in head first.

### Hat-tip

The talented [Nick Quaranto](http://litanyagainstfear.com/) has been
working hard on this for a while, and it’s great to see the Ruby
community embrace Gemcutter so quickly. Here’s hoping it becomes the
defacto gem source for all Ruby projects.

------------------------------------------------------------------------

<div class="comments">
<div class="comment-author">
<a href="http://litanyagainstfear.com">Nick Quaranto</a> left a comment
on 7 Oct, 2009:</div>

<div class="comment" markdown="1">
Pat, just a correction or two:

All you have to do is gem migrate \[name\]. You don’t have to pass in a
built gem, just the name will do.

Also, doing gem tumble with sudo will make root own your ~/.gemrc, I’m
not sure if that’s good for everyone, but it certainly will work!

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 7 Oct,
2009:</div>

<div class="comment" markdown="1">
Thanks for the feedback Nick, have just updated those commands as
suggested.

</div>
</div>

