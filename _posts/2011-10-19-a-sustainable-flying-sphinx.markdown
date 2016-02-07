---
title: "A Sustainable Flying Sphinx?"
redirect_from: "/posts/a_sustainable_flying_sphinx/"
categories:
  - web
  - sustainability
  - flying sphinx
  - programming
  - sphinx
  - rails
---
In which I muse about what a sustainable web service could look like -
but first, the backstory:

A year ago - almost to the day - I sat in a wine bar in Sydney’s Surry
Hills with [Steve Hopkins](http://www.thesquigglyline.com/). I’d been
thinking about how to get Sphinx working on Heroku, and ran him through
the basic idea in my head of how it could work. His first question was
“So, what are you working on tomorrow, then?”

By the end of the following day, I had some idea of how it would work.
Over the next few months I had a proof of concept working, hit some
walls, began again, and finally got to a point where I could launch an
alpha release of [Flying Sphinx](http://flying-sphinx.com).

In May, Flying Sphinx became available for all Heroku users - and
earlier today (five months later), I received my monthly provider
payment from Heroku, with the happy news that I’m now earning enough to
cover all related ongoing expenses - things like
[AWS](http://aws.amazon.com/) for the servers,
[Scalarium](http://www.scalarium.com/) to manage them, and
[Tender](http://tenderapp.com/) for support.

Now, I’m not rolling in cash, and I’m certainly not earning enough
through Flying Sphinx to pay rent, let alone be in a position to drop
all client work and focus on Flying Sphinx full-time. That’s cool,
either of those targets would be amazing.

And of course, money isn’t the be all and end all - even though this is
a business, and I certainly don’t want to run at a loss. I want Flying
Sphinx to be *sustainable* - in that it covers not only the hosting
costs, but my time as well, along with supporting the broader system
around it - code, people and beyond.

But what does a sustainable web service look like, particularly beyond
the standard (outmoded) financial axis?

### Sustainable Time

Firstly (and selfishly), it should cover the time spent maintaining and
expanding the service. Flying Sphinx doesn’t use up a huge amount of my
time right at the moment, but I’m definitely keen to improve a few
things (in particular, offer Sphinx 2.0.1 alongside the existing
1.10-beta installation), and there is the occasional support query to
deal with.

This one’s relatively straight-forward, really - I can track all time
spent on Flying Sphinx and multiply that by a decent hourly rate. If it
turns out I can’t manage all the work myself, then I pay someone else to
help.

It certainly doesn’t look like I’m going to need anyone helping in the
near future, mind you - nor am I drowning in support requests.

### Sustainable Software

Ignoring the time I spend writing code for Flying Sphinx (as that’s
covered by the previous section), pretty much every other piece of
software involved with the service is open source. Front and centre
among these is [Sphinx](http://sphinxsearch.com) itself.

I certainly don’t expect to be paid for my own open source
contributions, but it certainly helps when there’s some funds trickling
in to help motivate dealing with support questions, fixing bugs and
adding features. It can also provide a stronger base to build a
community as well.

With this in mind, I’m considering setting aside a percentage of any
profit for Sphinx development - as any improvements to that help make
Flying Sphinx a stronger offering.

(I could also cover my time spent on Thinking Sphinx either with a
percentage cut - either way it would end up in my pocket though.)

### Sustainable Hardware

This is where things get a little trickier - we’re not just dealing with
bits and electrons, but also silicon and metals. The human race is
pretty bad at weaning itself off of limited (as opposed to renewable)
resources, and the hardware industry certainly is going to hit some
limits in the future as certain metals become harder to source.

Of course, the servers use a lot of energy, so one thing I will be doing
is offsetting the carbon. I’ve not yet figured out the best service to
do this, but will start by looking at [Brighter
Planet](http://brighterplanet.com/).

From a social perspective, there’s also questions about how those
resources are sourced. We should be considering the working conditions
of where the metals are mined (and by whom), the people who are
soldering the logic boards, and those who place the finished products
into racks in data centres.

As an example, let’s look at Amazon. Given the [recent issues
raised](http://www.mcall.com/news/local/amazon/) with the conditions for
staff in their warehouses, I think it’s fair to seek clarification on
the situation of their web service colleagues. And what if there were
significant ethical issues for using AWS? What then for Flying Sphinx,
which runs EC2 instances and is an add-on for Heroku, a business built
entirely on top of Amazon’s offerings?

I could at least use servers elsewhere - but that means bandwidth
between servers and Heroku apps starts to cost money - and we introduce
a step of latency into the service. Neither of those things are ideal.
Or I could just say that I don’t want to support Amazon at all, and shut
down Flying Sphinx, remove all my Heroku apps, and find some other
hosting service to use.

Am I getting a little too carried away? Perhaps, but this is all
hypothetical anyway. I’m guessing Amazon’s techs are looked after
decently (though I’d love some confirmation on this), and am hoping the
situation improves for their warehouse staff as well.

I am still searching for answers for what truly sustainable hardware -
and moreso, sustainable web services - financially, socially,
environmentally, and technically. What’s your take? What have I
forgotten?

------------------------------------------------------------------------

<div class="comments">
<div class="comment-author">
Jean-Michel GARNIER left a comment on 20 Feb, 2012:</div>

<div class="comment" markdown="1">
At euruko 201, I made some crude comment about your carbon footprint
coming to Berlin and Australia carbon footprint.

After reading that post, I have to apologize publicly. I did not know
you and made a very premature judgement.

Regarding sustainability, Germany is the country to follow. Australia
has so much sun that I expect solar panels to power datacenters as soon
as there will be some political will and awareness.

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 11 Mar,
2012:</div>

<div class="comment" markdown="1">
Hi Jean-Michel

Thanks for your apology, although I didn’t take offence. I know the
carbon impact of such a trip isn’t great, and it’s a major disadvantage
of being in Melbourne. I certainly opt for carbon offsets for the
flights I take, though I know not taking the flight in the first place
would be better.

That said, I will be back in Europe for Euruko this year, but I’ll be
staying for four months, to make the most of such a long (and
environmentally shocking) trip.

And yes, things in Australia could certainly improve dramatically with
regards to solar power if we had the political will - the big question
is whether we will ever have such will from those in power. I’m sadly
not expecting it any time in the next few years. Europe generally (and
much closer to home, New Zealand) seems to be far smarter than us.

</div>
</div>

