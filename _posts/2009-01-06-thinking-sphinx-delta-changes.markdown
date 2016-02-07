---
title: "Thinking Sphinx Delta Changes"
redirect_from: "/posts/thinking_sphinx_delta_changes/"
categories:
  - plugins
  - search
  - sphinx
  - ruby
  - rails
---
There’s been a bit of changes under the hood with Thinking Sphinx
lately, and some of the more recent commits are pretty useful.

### Small Stuff

First off, something neat but minor - you can now use `decimal`, `date`
and `timestamp` columns as attributes - the plugin automatically maps
those to `float` and `datetime` types as needed.

There’s also now a cucumber-driven set of feature tests, which can run
on MySQL and PostgreSQL. While that’s not important to most users, it
makes it much less likely that I’ll break things. It’s also useful for
the numerous contributors - just over 50 people as of this week! You all
rock!

### New Delta Possibilities

The major changes are around delta indexing, though. As well as the
default delta column approach, there’s now two other methods of getting
your changes into Sphinx. The first, requested by some Ultrasphinx
users, and heavily influenced by [a fork by Ed
Hickey](http://blog.edhickey.com/2008/09/15/thinkingsphinx-rails-plugin-fork/),
is datetime-driven deltas. You can use a `datetime` column (the default
is `updated_at`), and then run the `thinking_sphinx:index:delta` rake
task on a regular basis to load recent changes into Sphinx.

Your `define_index` block would look something like the following:

    define_index do
      # ... field and attribute definitions

      set_property :delta => :datetime, :threshold => 1.day
    end

If you want to use a column other than `updated_at`, set it with the
`:delta_column` option.

The above situation is if you’re running the rake task once a day. The
more often you run it, the lower you can set your threshold. This is a
bit different to the normal delta approach, as changes will *not* appear
in search results straight away - only whenever the rake task is run.

### Delayed Reaction

One of the biggest complaints with the default delta structure is that
it didn’t scale. Your delta index got larger and larger every time
records were updated, and that meant each change got slower and slower,
because the indexing time increased. When running multiple servers, you
could get a few `indexer` processes running at once. That ain’t good.

So now, we have delayed deltas, using the
[delayed\_job](http://github.com/tobi/delayed_job) plugin. You’ll need
to have the job queue being processed (via the
`thinking_sphinx:delayed_delta` rake task), but everything is pushed off
into that, instead of overloading your web server. It means the changes
take slightly longer to get into Sphinx, but that’s almost certainly not
going to be a problem.

Firstly, you’ll need to create the `delayed_jobs` table (see the
delayed\_job readme for example code), and then change your
define\_index block so it looks something like this:

    define_index do
      # ... field and attribute definitions

      set_property :delta => :delayed
    end

### Riddle Update

As part of the restructuring over the last couple of months, I’ve also
added some additional code to Riddle, my Ruby API for Sphinx. It now has
objects to represent all of the configuration elements of Sphinx (ie:
settings for sources, indexes, indexer and searchd), and can generate
the configuration file for you. This means you don’t need to worry about
doing text manipulation, just do everything in neat, clean Ruby.

Documentation on this is non-existent, mind you, but the source
shouldn’t be too hard to grok. I also need to update Thinking Sphinx’s
documentation to cover the delta changes - for now, this blog post will
have to do. If you get stuck, check out the [Google
Group](http://groups.google.com/group/thinking-sphinx).

### Sphinx 0.9.9

One more thing: [Thinking
Sphinx](http://github.com/freelancing-god/thinking-sphinx/tree/sphinx-0.9.9)
and [Riddle](http://github.com/freelancing-god/riddle/tree/0.9.9) now
both have Sphinx 0.9.9 branches - not merged into master, as most people
are still using Sphinx 0.9.8, but you can find both code sets on GitHub.

------------------------------------------------------------------------

<div class="comments">
<div class="comment-author">
<a href="http://patrick.veverka.net">Patrick Veverka</a> left a comment
on 6 Jan, 2009:</div>

<div class="comment" markdown="1">
Wow, thanks for this great update. Is there anything different in the
new version of Sphinx or Thinking Sphinx that would cause issues with
wildcard searches? We’re using an older version of the plugin on one
site and it does wildcard searches perfectly fine (i.e. searching for
“P” returns “Patrick”, “Parker”, etc.) but when the latest version is
installed on a brand new MacBook Pro, it returns no results.

</div>
<div class="comment-author">
<a href="http://www.catalystmediastudios.com">Paul Smith</a> left a
comment on 6 Jan, 2009:</div>

<div class="comment" markdown="1">
Awesome! I just emailed you about this a couple weeks ago and you’ve
already added these changes. Thanks so much for all your hard work and
an awesome plugin!

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 7 Jan,
2009:</div>

<div class="comment" markdown="1">
Paul: No problems, glad to know it helps make life easier :)

Patrick: There shouldn’t be anything in Thinking Sphinx that’s caused
that change (although there has been a fair bit of work done, so I can’t
say for sure). If you’re running Sphinx 0.9.9, I really have no idea…
were you using allow\_star or enable\_star? Perhaps let’s continue this
discussion on the [google
group](http://groups.google.com/group/thinking-sphinx?)

</div>
<div class="comment-author">
<a href="http://nikolay.com">Nikolay Kolev</a> left a comment on 9 Jan,
2009:</div>

<div class="comment" markdown="1">
Are you gonna implement some of the missing features compared to
Ultrasphinx anytime soon?

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 10 Jan,
2009:</div>

<div class="comment" markdown="1">
Hi Nikolay

The only one that I know I’m missing is facets - which I’ve been
researching a bit lately. Is there anything else I’ve missed?

</div>
<div class="comment-author">
<a href="http://simplewebapp.de">Roman Heinrich</a> left a comment on 12
Jan, 2009:</div>

<div class="comment" markdown="1">
Yeah, faceted search would be VERY cool! I’m using thinking sphinx and
the only thing I miss from SOLR is faceted search… Very handy indeed. Is
this a hard thing to implement? Maybe the first results are just a
couple of hours coding.

Thanks for this amazing plugin!

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 12 Jan,
2009:</div>

<div class="comment" markdown="1">
Hi Roman

Some people have put together quick solutions - if you search on the
google group you should find some references to them. I still don’t feel
I understand facets as a concept just yet - although getting close. Want
to make sure the solution is solid for TS.

</div>
<div class="comment-author">
<a href="http://www.touchlocal.com">Romain</a> left a comment on 19 Jan,
2009:</div>

<div class="comment" markdown="1">
Hi,

I was wondering what are the main differences of ThinkingSphinx plugin
over UltraSphinx and the other ruby/rails interface to Sphinx ? I am
trying to establish which to use for my app.

Any hints and tips welcome !

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 20 Jan,
2009:</div>

<div class="comment" markdown="1">
Hi Romain

While faceted search is mentioned in above comments, I’ve since [added
that](http://gist.github.com/48328) to Thinking Sphinx. I’m not sure if
UltraSphinx supports excerpts, but that’s the main Sphinx feature
Thinking Sphinx doesn’t yet support (although there’s a fork or two out
there that does, and I do plan to add it).

There is also [a comparison blog
post](http://reinh.com/blog/2008/07/14/a-thinking-mans-sphinx.html) by
Rein Henrichs.

</div>
<div class="comment-author">
shawn left a comment on 27 Jan, 2009:</div>

<div class="comment" markdown="1">
What’s the trick for downloading the 0.9.9 version of the Riddle gem?
The github download link doesn’t seem to work…

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 27 Jan,
2009:</div>

<div class="comment" markdown="1">
Shawn: Ah, that’s not very helpful of GitHub. Try [this
link](http://github.com/freelancing-god/riddle/tarball/0.9.9) for the
tar file. You will then need to run `gem build riddle.gemspec` and then
install the gem file that gets generated.

</div>
<div class="comment-author">
jason left a comment on 25 Feb, 2009:</div>

<div class="comment" markdown="1">
The delta search is very impressive and being a new convert to the rails
community I’m extremely suprised how easy it is to take advantage of
such cool technology.  
One thing I’m struggling with however is that everything runs fine on my
local environment, but when I move it to our hosting company, it does
not seem to play well with mod\_rails. In the same environment I can
spin up mongrel and everything is as expected. Specifically, I have my
models configured for delta, and all new items added since last index
are still found - as i hoped. When using mod\_rails I do not get the
same outcome - I can see them through the console with regular search,
but not with sphinx search either - and their delta fields are set to
true.  
The support folks come back to me with - I’ve made some mods to the
vhost - try again. Still no luck.  
Is this something others have encountered and is it reasonable that it
can be fixed in the vhost file of apache?

Your help on this would be greatly appreciated.

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 26 Feb,
2009:</div>

<div class="comment" markdown="1">
Hi Jason

I know a lot of people have had issues with the PATH variable being
different for mod\_rails/passenger - so it doesn’t know about the Sphinx
executable `indexer`. That’d be the first thing I’d be checking for… If
that doesn’t work, let’s continue this discussion on [the google
group](http://groups.google.com/group/thinking-sphinx)

</div>
<div class="comment-author">
Tony Martin left a comment on 11 May, 2009:</div>

<div class="comment" markdown="1">
Could you clarify which is the stable version to install. The usage page
suggests checking out v0.9.5, but this does not appear to support delta
index. You mention 0.9.8 above, but cant install, I get ‘v0.9.8’ did not
match any file(s) known to git. I am using rails v2.1.1  
Thanks

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 11 May,
2009:</div>

<div class="comment" markdown="1">
Hi Tony

The usage page is woefully out-of-date when it comes to version numbers
- the latest version [on
GitHub](http://github.com/freelancing-god/thinking-sphinx/tree) is
1.1.10. I’ve not been adding tags though, but just get the latest
version, and things should work.

Cheers

</div>
<div class="comment-author">
rajesh left a comment on 5 Jun, 2009:</div>

<div class="comment" markdown="1">
<p>
Hi Pat,

I am using thinking sphinx in one of my applications which is search
based.  
It has lot of input every 15 minutes and needs to be indexed.

In my do\_index I have:  
<code>  
set\_property :delta =&gt; :datetime, :delta\_column =&gt; :updated\_at,
:threshold =&gt; 22.minutes  
</code>  
I run the cron for delta ‘rake thinking\_sphinx:index:delta
RAILS\_ENV=production’ every 20 minutes.

But the new data is not getting indexed in expected time.  
I see the new data in search results after a interval of 4-5 hours.  
Also, I have to explicitly reindex completely at times.

Not getting where exactly the problem is, am I missing anything?  
Do I need to do merge? I dont see ‘merge’ task in my rake list.

Also, I found some .tmp files created in the sphinx folder.  
I suspect if these are related to the problem in some way.  
Where can I find the significance of all these file types?

When I do

ls -l db/sphinx/production:

I see the following.

<code>  
total 259136  
-rw-r—r— 1 root root 7008576 Jun 4 09:20 item\_core.spa  
-rw-r—r— 1 root root 7102080 Jun 5 00:40 item\_core.spa.tmp  
-rw-r—r— 1 root root 96134630 Jun 4 09:20 item\_core.spd  
-rw-r—r— 1 root root 0 Jun 5 00:40 item\_core.spd.tmp  
-rw-r—r— 1 root root 347 Jun 4 09:20 item\_core.sph  
-rw-r—r— 1 root root 2687497 Jun 4 09:20 item\_core.spi  
-rw-r—r— 1 root root 0 Jun 5 00:40 item\_core.spi.tmp  
-rw-r—r— 1 root root 0 Jun 3 07:40 item\_core.spk  
<s>rw———</s> 1 root root 0 Jun 5 00:40 item\_core.spl  
-rw-r—r— 1 root root 2628216 Jun 4 09:20 item\_core.spm  
-rw-r—r— 1 root root 2097152 Jun 5 00:40 item\_core.spm.tmp  
-rw-r—r— 1 root root 143840229 Jun 4 09:20 item\_core.spp  
-rw-r—r— 1 root root 0 Jun 5 00:40 item\_core.spp.tmp  
-rw-r—r— 1 root root 94240 Jun 5 00:40 item\_delta.spa  
-rw-r—r— 1 root root 1302450 Jun 5 00:40 item\_delta.spd  
-rw-r—r— 1 root root 347 Jun 5 00:40 item\_delta.sph  
-rw-r—r— 1 root root 171537 Jun 5 00:40 item\_delta.spi  
-rw-r—r— 1 root root 0 Jun 3 07:40 item\_delta.spk  
<s>rw———</s> 1 root root 0 Jun 5 00:40 item\_delta.spl  
-rw-r—r— 1 root root 35340 Jun 5 00:40 item\_delta.spm  
-rw-r—r— 1 root root 1923426 Jun 5 00:40 item\_delta.spp  
</code>

Thanks,  
Rajesh

</p>
</div>
</div>

