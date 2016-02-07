---
title: "A Month in the Life of Thinking Sphinx"
redirect_from: "/posts/a_month_in_the_life_of_thinking_sphinx/"
categories:
  - search
  - sphinx
  - thinking sphinx
  - ruby
  - rails
---
It’s just over two months since [I asked for - and
received](http://freelancing-gods.com/posts/funding_thinking_sphinx) -
support from the Ruby community to work on Thinking Sphinx for a month.
A review of this would be a good idea, hey?

I’m going to write a separate blog post about how it all worked out, but
here’s a long overview of the new features.

### Internal Cucumber Cleanup

This one’s purely internal, but it’s worth knowing about.

Thinking Sphinx has a growing set of Cucumber features to test behaviour
with a live Sphinx daemon. This has made the code far more reliable, but
there was a lot of hackery to get it all working. I’ve cleaned this up
considerably, and it is now re-usable for other gems that extend
Thinking Sphinx.

### External Delta Gems

Of course, it was my own re-use that was driving that need: I wanted to
use it in gems for the [delayed
job](http://github.com/freelancing-god/ts-delayed-delta/) and [datetime
delta](http://github.com/freelancing-god/ts-datetime-delta/) approaches.

There was a clear need for removing these two pieces of functionality
from Thinking Sphinx: to keep the main library as slim as possible, and
to make better use of gem dependencies, allowing people to use whichever
version of delayed job they like.

So, if you’ve not upgraded in a while, it’s worth re-reading [the delta
page of the
documentation](http://freelancing-god.github.com/ts/en/deltas.html),
which covers the new setup pretty well.

### Testing Helpers

Internal testing is all very well, but what’s much more useful for
everyone using Thinking Sphinx is the new testing class. This provides a
clean, simple interface for processing indexes and starting the Sphinx
daemon.

There’s also a Cucumber world that simplifies things even further -
automatically starting and stopping Sphinx when your features are run.
I’ve been using this myself in a project over the last few days, and I’m
figuring out a neat workflow. More details soon, but in the meantime,
have a read through [the
documentation](http://freelancing-god.github.com/ts/en/testing.html).

### No Vendored Code for Gems

One of the uglier parts of Thinking Sphinx is the fact that it vendors
[Riddle](http://github.com/freelancing-god/riddle/) and
[AfterCommit](http://github.com/freelancing-god/after_commit/) (and for
a while, Delayed Job), two essential libraries. This is not ideal at
all, particularly when gem dependencies can manage this for you.

So, Thinking Sphinx no longer vendors these libraries if you install it
as a gem - instead, the `riddle` and `after_commit` gems will get
brought along for the ride.

The one catch is that they’re still vendored for plugin installations. I
recommend people use Thinking Sphinx as a gem, but there are valid
reasons for going down the plugin path.

### Default Sphinx Scopes

Thanks to some hard work by [Joost Hietbrink](http://github.com/joost)
of the Netherlands, Thinking Sphinx now supports default sphinx scopes.
All I had to do was merge this in - Joost was the first contributor to
Thinking Sphinx (and there’s now over 100!), so he knows the code pretty
well.

In lieu of any real documentation, here’s a quick sample - define a
scope normally, and then set it as the default:

    class Article < ActiveRecord::Base
      # ...

      sphinx_scope(:by_date) {
        {:order => :created_at_}
      }

      default_sphinx_scope :by_date

      # ...
    end

### Thread Safety

I’ve made some changes to improve the thread safety of Thinking Sphinx.
It’s not perfect, but I think all critical areas are covered. Most of
the dynamic behaviour occurs when the environment is initialised anyway.

That said, I’m anything but an expert in this area, so consider this a
tentative feature.

### Sphinx Select Option

Another community-sourced patch - this time from [Andrei
Bocan](http://spinach.andascarygoat.com/) in Romania: if you’re using
Sphinx 0.9.9, you can make use of its [custom select
statements](http://www.sphinxsearch.com/docs/manual-0.9.9.html#api-func-setselect):

    Article.search 'pancakes',
      :sphinx_select => '*, @weight + karma AS superkarma'

This is much like the `:select` option in ActiveRecord - but make sure
you use `:sphinx_select` (as the former gets passed through to
ActiveRecord’s find calls).

### Multiple Index Support

You can now have more than one index in a model. I don’t see this as
being a widely needed feature, but there’s definitely times when it
comes in handy (such as having one index with stemming, and one
without). The one thing to note is that all indexes after the first one
need explicit names:

    define_index 'stemmed' do
      # ...
    end

You can then specify explicit indexes when searching:

    Article.search 'pancakes',
      :index => 'stemmed_core'
    Article.search 'pancakes',
      :index => 'article_core,stemmed_core'

Don’t forget that the default index name is the model’s name in
lowercase and underscores. All indexes are prefixed with `_core`, and if
you’ve enabled deltas, then a matching index with the `_delta` suffix
exists as well.

Building on from this, you can also now have indexes on STI subclasses
when superclasses are already indexed.

While the commits to this feature are mine, I was reading code from a
patch by [Jonas von Andrian](http://github.com/johnny) - so he’s the
person to thank, not me.

### Lazy Initialisation

Thinking Sphinx needs to know which models have indexes for searching
and indexing - and so it would load every single model when the
environment is initialised, just to figure this out. While this was
necessary, it also is slow for applications with more than a handful of
models… and in development mode, this hit happens on every single page
load.

Now, though, Thinking Sphinx only runs this load request when you’re
searching or indexing. While this doesn’t make a difference in
production environments, it should make life on your workstations a
little happier.

### Lazy Index Definition

In a similar vein, anything within the `define_index` block is now
evaluated when it’s needed. This means you can have it *anywhere* in
your model files, whereas before, it had to appear after association
definitions, else Thinking Sphinx would complain that they didn’t exist.

This feature actually introduced a fair few bugs, but (thanks to some
patience from early adopters), it now runs smoothly. And if it doesn’t,
you know [where to find
me](http://groups.google.com/group/thinking-sphinx/).

### Sphinx Auto-Version detection

Over the course of the month, Thinking Sphinx and Riddle went through
some changes as to how they’d be required (depending on your version of
Sphinx). First, there was separate gems for 0.9.8 and 0.9.9, and then
single gems with different require statements. Neither of these
approaches were ideal, which [Ben
Schwarz](http://www.germanforblack.com/) clarified for me.

So I spent a day or two working on a solution, and now Thinking Sphinx
will automatically detect which version you have installed. You don’t
need any version numbers in your require statements.

The one catch with this is that you currently need Sphinx installed on
every machine that needs to know about it, including web servers that
talk to Sphinx on a separate server. There’s [an issue logged for
this](http://github.com/freelancing-god/thinking-sphinx/issues#issue/73),
and I’ll be figuring out a solution soon.

### Sphinx 0.9.9

This isn’t quite a Thinking Sphinx feature, but it’s worth noting that
Sphinx 0.9.9 final release is [now
available](http://sphinxsearch.com/downloads.html). If you’re upgrading
(which should be painless), the one thing to note is that the default
port for Sphinx has changed from 3312 to 9312.

### Upgrading

If you want to grab the latest and greatest Thinking Sphinx, then
version 1.3.14 is what to install. And read [the documentation on
upgrading](http://freelancing-god.github.com/ts/en/upgrading.html)!

------------------------------------------------------------------------

<div class="comments">
<div class="comment-author">
Michael left a comment on 3 Jan, 2010:</div>

<div class="comment" markdown="1">
Thanks for the hard work mate!

</div>
<div class="comment-author">
James Healy left a comment on 3 Jan, 2010:</div>

<div class="comment" markdown="1">
An impressive list Pat - those that donated certainly got value for
money.

I’ve upgraded our production site to TS 1.3.14 and sphinx 0.9.9 and it’s
running smoothly, mainly due to the gem packaging related improvements
(single TS gem for 0.9.8 and 0.9.9, using external gems for delayed job,
etc)

</div>
<div class="comment-author">
<a href="http://www.comp.ufscar.br/~murilo">Murilo Soares Pereira</a>
left a comment on 3 Jan, 2010:</div>

<div class="comment" markdown="1">
Nice post Pat, thanks for this. I’ve just upgraded my app to sphinx
0.9.9 and it’s running perfectly.

</div>
<div class="comment-author">
<a href="http://www.learnivore.com">Thibaut Barrere</a> left a comment
on 3 Jan, 2010:</div>

<div class="comment" markdown="1">
Wow - thank you so much pat! Great work.

</div>
<div class="comment-author">
<a href="http://www.updrift.com">Wade Winningham</a> left a comment on 3
Jan, 2010:</div>

<div class="comment" markdown="1">
Awesome, Pat. Thanks so much. I’m especially proud of the community
you’ve got around you that enabled you to do this.

</div>
<div class="comment-author">
<a href="http://tomafro.net">Tom Ward</a> left a comment on 6 Jan,
2010:</div>

<div class="comment" markdown="1">
Awesome work Pat. If you launch another funding drive, I will certainly
contribute.

</div>
<div class="comment-author">
<a href="http://dathompson.com">D.a. Thompson</a> left a comment on 7
Jan, 2010:</div>

<div class="comment" markdown="1">
Fantastic work, Pat. It’s encouraging seeing the community pull together
like that. And thanks for all of your hard work!

ps - I just spent the evening schooling a noob in the wonders of Ruby
(and Railsdom). It was nice to be able to point to this kind of
community and see him blown away.

</div>
<div class="comment-author">
<a href="http://humorial.ru">Alexey</a> left a comment on 30 Jan,
2010:</div>

<div class="comment" markdown="1">
thinking sphinx is great-great deal

</div>
</div>

