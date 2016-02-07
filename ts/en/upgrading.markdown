---
layout: ts_en
title: Upgrading
---


Upgrading Thinking Sphinx
-------------------------

Thinking Sphinx has changed quite a bit over time, and if you’re
upgrading from an old version, you may find some of your code needs to
be changed as well. Here’s a few tips…

### Checking the version number

In later versions of Thinking Sphinx, there is a rake task available to
check your version:

{% highlight sh %}  
rake thinking\_sphinx:version  
{% endhighlight %}

If you’re using an older version of Thinking Sphinx as a gem, then just
look at the gem version number. If you’ve got it installed as a plugin,
though, then you’re going to have to have a look at
`vendor/plugins/thinking_sphinx/lib/thinking_sphinx.rb`, as that’s where
the version number was stored.

### Upgrading from 2.0.0.rc2 to 2.0.0 or 1.3.20 to 1.4.0

In previous versions of Thinking Sphinx, it was valid to put attribute
filters in either `:with` or `:conditions`. For a long while, filters in
`:conditions` has been clearly flagged as deprecated, and since 1.4.0
and 2.0.0 it is now removed.

You can still use `:with` for attribute filters and `:conditions` for
field-focused queries.

### Upgrading from between 1.3.6 and 1.3.17

If you’re using excerpts, for this set of versions they were
automatically HTML-escaped. This is now no longer the case, as Sphinx
can take care of this automatically for both indexing and excerpts. Just
turn on the `html_strip` value in your `sphinx.yml` file:

{% highlight yaml %}  
html\_strip: true  
{% endhighlight %}

### Upgrading from between 1.3.3 and 1.3.7

You no longer have to specify an explicit Sphinx version when requiring
Thinking Sphinx - it will figure it out itself. So, you can remove the
version require statement from your `Rakefile`, and remove the version
suffix in your gem setup in `environment.rb`.

### Upgrading from 1.3.2 or earlier (when using Sphinx 0.9.9)

If you’ve been using the `sphinx-0.9.9` branch from GitHub or the
`thinking-sphinx-099` gem, there is now just one version of Thinking
Sphinx that works for both versions (and automatically detects which
version you have). The installation page provides a good overview of the
new setup.

{% highlight ruby %}  
config.gem(  
 ‘thinking-sphinx’,  
 :lib =&gt; ‘thinking\_sphinx’,  
 :version =&gt; ‘1.3.8’  
)  
{% endhighlight %}

### Upgrading from 1.2.13 or earlier

With the advent of Thinking Sphinx 1.3.0, the
[delayed](http://github.com/pat/ts-delayed-delta/) and
[datetime](http://github.com/pat/ts-datetime-delta/) delta approaches
are now in separate gems. Also, Delayed Job is no longer vendored in
Thinking Sphinx, so you may need to install it as a plugin as well.

The delta page has been updated to reflect these changes, so [have a
read through that](deltas.html) to figure out how to make sure your
application will still work.

If you’re not using deltas, or only using the default delta approach,
then this change does not affect you.

### Upgrading from 1.1.17 or earlier

In versions of Thinking Sphinx *before* 1.1.18, the morphology/stemmer
defaulted to stem\_en (English). Obviously, not every website uses the
English language, so this setting has been removed, with no stemmer as
the default.

If you would like to keep stem\_en as your stemmer, you’ll need to add
it to your `config/sphinx.yml` file:

{% highlight yaml %}  
development:  
 morphology: stem\_en  
test:  
 morphology: stem\_en  
production:  
 morphology: stem\_en  
{% endhighlight %}

To get a better understanding of stemmers, I recommend reading [Sphinx’s
documentation](http://www.sphinxsearch.com/docs/manual-0.9.8.html#conf-morphology).
