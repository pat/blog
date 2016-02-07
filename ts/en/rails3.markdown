---
layout: ts_en
title: Rails 3
---


Using Thinking Sphinx with Rails 3
----------------------------------

Not much has changed - it’s really just installation that is a little
different.

### Installing via Bundler (as a Gem)

The 2.x releases of Thinking Sphinx will only support Rails 3 - not
Rails 2 or earlier. So be careful with managing gem dependencies across
multiple Rails versions. It may be worth looking at
[RVM](http://rvm.beginrescueend.com/).

In your Gemfile, you’ll need to add the following:

{% highlight ruby %}  
gem ‘thinking-sphinx’, ‘2.0.10’  
{% endhighlight %}

Of course, you can point directly to the Git repository if you so desire
- just make sure you’re referencing a commit (probably the most recent)
from the master branch:

{% highlight ruby %}  
gem ‘thinking-sphinx’,  
 :git =&gt; ‘git://github.com/pat/thinking-sphinx.git’,  
 :ref =&gt; ‘8f0e34b4a68494738d8dd5a1cb6bcf379adbf640’  
{% endhighlight %}

You do *not* need to put the extra `require` statement in your Rakefile
- Rails 3 can determine this automatically (well, when Thinking Sphinx
tells it to).

### Installing as a Plugin

Things are even simpler if you want Thinking Sphinx installed as a
plugin, instead of managed by Bundler - just run the following shell
command from within your Rails app:

{% highlight sh %}  
script/rails plugin install \\  
 git://github.com/pat/thinking-sphinx.git  
{% endhighlight %}

I don’t recommend this option though - I think it’s best to keep all
dependencies in one place, and with Rails 3, the `Gemfile` is that one
place.
