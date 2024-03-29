---
title: "Gutentag: Simple Rails Tagging"
redirect_from: "/posts/gutentag_simple_rails_tagging/"
categories:
  - ruby
  - rails
  - gems
  - examples
excerpt: "The last thing the Rails ecosystem needs is another tagging gem. But I went and built one anyway… it’s called Gutentag, and perhaps worth it for the name alone (something I get an inordinate amount of happiness from)."
---
The last thing the Rails ecosystem needs is another tagging gem. But I
went and built one anyway… it’s called
[Gutentag](http://github.com/pat/gutentag), and perhaps worth it for the
name alone (something I get an inordinate amount of happiness from).

My reasons for building Gutentag are as follows:

A tutorial example
------------------

I ran a workshop at [RailsConf](http://railsconf.com/) earlier this year
(as a pair to [this
talk](http://confreaks.com/videos/2482-railsconf2013-crafting-gems)),
and wanted a simple example that people could work through to have the
experience of building a gem. Almost every Rails app seems to need tags,
so I felt this was a great starting point - and a great way to show off
how simple it is to write and publish a gem.

You can work through [the
tutorial](https://web.archive.org/web/20151213065745/http://railsconftutorials.com/2013/sessions/crafting_gems.html)
yourself if you like - though keep in mind the focus is more on the
process of building a gem rather than the implementation of this gem in
particular.

A cleaner code example
----------------------

Many gems aren’t good object-oriented citizens - and this includes most
of the ones I’ve written. They’re built with long, complex classes and
modules, are structured in ways that
[Demeter](http://en.wikipedia.org/wiki/Law_of_Demeter) does not like,
and aren’t particularly easy to extend cleanly.

I have the beginnings of a talk on how to structure gems (especially
those that work with Rails) sensibly - but I’ve not yet had the
opportunity to present this at any conferences.

One point that will definitely feature if I ever do get that
opportunity: more and more, I like to avoid including modules into
ActiveRecord and other parts of Rails - and if you peruse the source
you’ll see I’m only adding [the absolute
minimum](https://github.com/pat/gutentag/blob/master/lib/gutentag/active_record.rb)
to ActiveRecord::Base, plus I’ve pulled out the logic around the tag
names collection and resulting persistence into a [separate, simple
class](https://github.com/pat/gutentag/blob/master/lib/gutentag/persistence.rb).

I got a nice little buzz when I had [Code
Climate](https://codeclimate.com) scan the source and give it [an A
rating](https://codeclimate.com/github/pat/gutentag/) without me needing
to change anything.

Test-driven design
------------------

I started with tests, and wrote them in a way that made it clear how I
expected the gem to behave - and then wrote the implementation to match.
If you’re particularly keen, you can scan through [each
commit](https://github.com/pat/gutentag/commits/master) to see how the
gem has evolved - I tried to keep them small and focused.

Or, just have a read through of the acceptance test files - there’s
[only](https://github.com/pat/gutentag/blob/master/spec/acceptance/tags_spec.rb)
[two](https://github.com/pat/gutentag/blob/master/spec/acceptance/tag_names_spec.rb),
so it won’t take you long.

So?
---

There are a large number of other tagging gems out there - and if you’re
using one of those already, there’s no incentive at all to switch. I’ve
used acts-as-taggable-on many times without complaints.

But Gutentag certainly works - the
[README](https://github.com/pat/gutentag/blob/master/README.md) outlines
how you can use it - and at least people might smile every time they add
it to a Gemfile. But at the end of the day, if it’s just used as an
example of a simple gem done well, I’ll consider this a job well done.
