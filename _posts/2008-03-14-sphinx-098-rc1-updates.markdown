---
title: "Sphinx 0.9.8-rc1 Updates"
redirect_from: "/posts/sphinx_098_rc1_updates/"
categories:
  - plugins
  - search
  - sphinx
  - ruby
  - rails
---
Another small sphinx-related post.

In line with the first release candidate release of [Sphinx
0.9.8](http://sphinxsearch.com/) last week, I’ve updated both my API,
[Riddle](http://riddle.freelancing-gods.com), and my plugin, [Thinking
Sphinx](http://ts.freelancing-gods.com), to support it. Also, for those
inclined, you can now get Riddle as a gem.

I’m slowly making progress on some major changes to Thinking Sphinx, so
hopefully I’ll have something cool to show people soon. Oh, but some
features that aren’t reflected in the documentation: most of Sphinx’s
search options can be passed through when you call Model.search -
including `:group_by`, `:group_function`, `:field_weights`,
`:sort_mode`, etc. Consider it an exercise for the reader to figure out
the details until I get around to improving the docs.

------------------------------------------------------------------------

<div class="comments">
<div class="comment-author">
<a href="http://www.fonzz.com">jney</a> left a comment on 14 Mar,
2008:</div>

<div class="comment" markdown="1">
i’m just interesting about sphinx some days ago. what are the difference
main differences between Thinking Sphinx and ultrasphinx?

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 14 Mar,
2008:</div>

<div class="comment" markdown="1">
jney: Thinking Sphinx doesn’t have quite all the features that
Ultrasphinx does - but I think it covers everything most users need it
for. It also handles multiple-association fields in sphinx indexes more
elegantly.

They’re both solid options though - it really depends on how you need to
use Sphinx.

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 14 Mar,
2008:</div>

<div class="comment" markdown="1">
Also: they both use Riddle to talk to Sphinx itself, so there’s
definitely a level of similarity under the hood.

</div>
<div class="comment-author">
<a href="http://www.ravelry.com">Casey</a> left a comment on 20 Mar,
2008:</div>

<div class="comment" markdown="1">
Thanks so much for keeping Riddle up-to-date with the fast-moving
development of Sphinx. Riddle is great - it’s nice to have a Ruby API
that looks like Ruby.

oh - are multi-valued attributes supported w/0.9.8rc1? I’m get some
crazy behavior (weird results or errors during parsing the response)
Figured I’d mention it in case someting comes to mind…

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 22 Mar,
2008:</div>

<div class="comment" markdown="1">
Casey: Andrew certainly keeps me on my toes with his regular releases of
Sphinx.

I’ve just tweaked Riddle to support MVA fully - it kinda did before, but
now it’s at a level where I’m satisfied with it. The new gem will take a
couple of hours to filter through, but both trunk and the rc1 tag in SVN
are updated as well.

The public release of Thinking Sphinx doesn’t yet support MVA, but the
rewrite I’m working on does.

</div>
<div class="comment-author">
Thuva left a comment on 27 Mar, 2008:</div>

<div class="comment" markdown="1">
Is there any way to use Thinking Sphinx along with GeoKit
(http://geokit.rubyforge.org)?

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 27 Mar,
2008:</div>

<div class="comment" markdown="1">
Thuva: Sphinx itself can search on lat/lon values in relation to
distance, if those values are in the indexes as attributes - so that can
be done through Thinking Sphinx, yes.

The geocoding of street addresses into lat/lon values, though, is
something you’d need to use GeoKit to do.

Syntax examples from both the current release and the rewrite (soon! I
promise) can be found in [this
pastie](http://pastie.textmate.org/private/dkidyl4svxj8yytybfqng) - but
keep in mind you need to store lat and lon values in your database (and
thus in your index) as radians, not degrees - so you will need to
translate GeoKit’s values accordingly.

</div>
<div class="comment-author">
Thuva left a comment on 28 Mar, 2008:</div>

<div class="comment" markdown="1">
Pat: Thank you for the information regarding geosearch using Thinking
Sphinx plugin.

I’m not sure how to apply your example to my situation. I want to search
for places based on the name and address.

I’ve posted a pastie
(http://pastie.textmate.org/private/wxv6cbzunzxzuvv2qsjrzw) that
describes my sample problem as well as the solution. Please let me know
whether I’m on the right path.

Thinking Sphinx is a terrific plugin. I’m making the jump from Ferret to
Sphinx after looking at this plugin and realizing how easy it is.

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 28 Mar,
2008:</div>

<div class="comment" markdown="1">
Thuva: Looks like you’re doing a few things that aren’t quite supported
in the current public release (you’ll need attributes via associations
for lat and lon values, and the :geo option isn’t in SVN yet).

Over the weekend I’ll tidy the rewrite up and let you know when it’s at
a usable state so you can get all the nice new features as soon as
possible.

Sorry to have it so close but not usable just yet for what you need…

</div>
<div class="comment-author">
Aaron left a comment on 22 May, 2008:</div>

<div class="comment" markdown="1">
This is great stuff, really impressive work!

I’ve migrated from UltraSphinx to ThinkingSphinx with nearly no problems
at all.

Though I **am** having some problems with the geo distancing stuff.
Literally as soon as I introduce @geodist into anything, I get back zero
results.

I’ve confirmed that the indexes have the correct values as attributes in
radians using the sphinx CLI search client. But no love from Thinking
Sphinx. :(

Anyone have **working** @geodist examples?

</div>
<div class="comment-author">
Aaron left a comment on 22 May, 2008:</div>

<div class="comment" markdown="1">
Err, I guess I was leaving of the directional part of the order clause.
Make sure to include ASC or DESC in your :order.

</div>
<div class="comment-author">
Aaron left a comment on 22 May, 2008:</div>

<div class="comment" markdown="1">
I figured I’d post another thing here that tripped me up for a while.

When filtering on @geodist, you need to use a range of **floats** in
meters. e.g. (0.0..2000.0) would show only results in 2km.

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 26 May,
2008:</div>

<div class="comment" markdown="1">
Hi Aaron - great to have the feedback, and the pointers for how you got
it working (I didn’t know about the need to use floats in metre ranges).

If anything else crops up, don’t hesitate to get in touch (or perhaps
post to the [google
group](http://groups.google.com/group/thinking-sphinx))

</div>
<div class="comment-author">
shawn left a comment on 24 Jun, 2008:</div>

<div class="comment" markdown="1">
Is there a way to call the Sphinx ResetFilters or ResetGroupBy functions
via Riddle when appending multiple queries for multi-query? I don’t see
how to do that in the API or source. If there isn’t a way to do it yet,
consider this a feature request. ;)

BTW, thanks for Riddle, it’s great to have a ruby-like API for Sphinx!
:)

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 24 Jun,
2008:</div>

<div class="comment" markdown="1">
Shawn: there isn’t, so I’ll try to add it soon. Thanks for the feedback
:)

</div>
</div>

