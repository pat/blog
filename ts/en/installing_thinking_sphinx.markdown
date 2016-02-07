---
layout: ts_en
title: Installing Thinking Sphinx
---


Installing Thinking Sphinx
--------------------------

**Please note:** Using Rails 3? You’ll want to read [the new
instructions for that](rails3.html).

There’s a few different ways you can get Thinking Sphinx installed into
your web application. I **highly recommend** installing as a gem (and
indeed, if you’re using Merb, then you’ll have to use the gem). If
you’re using Rails and prefer a plugin, read through the options further
down the page.

### As a Gem

There’s a few steps to using Thinking Sphinx as a gem. Firstly, let’s
install it:

{% highlight sh %}  
gem install thinking-sphinx  
{% endhighlight %}

If you’re using Merb, then you just need to require the library within
your `init.rb`:

{% highlight ruby %}  
require ‘thinking\_sphinx’  
{% endhighlight %}

For Rails users, you’ll need to add the gem to your configuration setup
in `environment.rb`:

{% highlight ruby %}  
config.gem(  
 ‘thinking-sphinx’, :version =&gt; ‘1.4.10’  
)  
{% endhighlight %}

And one last thing: ensure the rake tasks are available by adding the
following lines to your `Rakefile`:

{% highlight ruby %}  
begin  
 require ‘thinking\_sphinx/tasks’  
rescue LoadError  
 puts “You can’t load Thinking Sphinx tasks unless the thinking-sphinx
gem is installed.”  
end  
{% endhighlight %}

Please note that if you’ve got Rails vendored, then this may not work so
neatly. Thinking Sphinx’s rake tasks load ActiveRecord, but it doesn’t
pick up on the vendored version - so you will [still need Rails gems
installed
normally](http://elliot-nelson.net/2010/02/thinking-sphinx-and-frozen-rails/)
as well.

### As a Plugin with Rails 2.1 or newer and Git

If you’ve got `git` installed, and are using Rails 2.1 or newer, then
it’s painless to get Thinking Sphinx installed in your Rails
application:

{% highlight sh %}  
script/plugin install \\  
 git://github.com/pat/thinking-sphinx.git  
{% endhighlight %}

### As a Plugin with Rails 2.0 or older and Git

If you’ve got `git`, but using one of the older versions of Rails, then
things are slightly more complicated.

{% highlight sh %}  
git clone \\  
 git://github.com/pat/thinking-sphinx.git \\  
 vendor/plugins/thinking\_sphinx  
cd vendor/plugins/thinking\_sphinx  
git checkout v1  
{% endhighlight %}

And if you want to make sure it all gets committed to git as part of
your main repository, don’t forget to remove the plugin’s .git
directory.

{% highlight sh %}  
rm -r vendor/plugins/thinking\_sphinx/.git  
{% endhighlight %}

### As a Plugin without Git

If you don’t have `git` installed, all is not lost. You can either
manually download the tarball from GitHub, and then extract it into your
`vendor/plugins` directory, or you can run the following shell commands
from the root of your Rails application, which do exactly the same
thing.

{% highlight sh %}  
curl -L \\  
 http://github.com/pat/thinking-sphinx/tarball/v1 \\  
 -o thinking-sphinx.tar.gz  
tar -xvf thinking-sphinx.tar.gz -C vendor/plugins  
mv vendor/plugins/freelancing-god-thinking-sphinx\* \\  
 vendor/plugins/thinking-sphinx  
rm thinking-sphinx.tar.gz  
{% endhighlight %}
