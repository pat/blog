---
layout: ts_en
title: Contributing to Thinking Sphinx
---


Contributing to Thinking Sphinx
-------------------------------

-   [Forking and Patching](#forking)
-   [Dependencies](#dependencies)
-   [Running Specs](#specs)
-   [Running Cucumber Features](#cucumber)
-   [Writing Third-Party Gems](#gems)

<h3 id="forking">
Forking and Patching</h3>

If you’re offering a patch to Thinking Sphinx, the best way to do this
is to fork [the GitHub project](http://github.com/pat/thinking-sphinx),
patch it, and then send me a Pull Request. This last step is important -
while I may be following your fork on GitHub, the request means an email
ends up in my inbox, so I won’t forget about your changes.

Do not forget to add specs - and features, if there’s any functionality
changes. This keeps Thinking Sphinx as stable as possible, and makes it
far easier for me to merge your changes in.

Sometimes I accept patches, sometimes I don’t. Please don’t be offended
if your patch falls into the latter category - I want to keep Thinking
Sphinx as lean as possible, and that means I don’t add every feature
that people request or write.

<h3 id="dependencies">
Dependencies</h3>

Thinking Sphinx’s specs are written with RSpec, and the integration
tests with Cucumber, so you’ll need both of these gems installed for
starters. You’ll also want to install YARD, RedCloth and BlueCloth for
documentation, and Jeweler for gem management and useful rake tasks.

{% highlight sh %}  
gem install rspec cucumber bluecloth RedCloth yard  
{% endhighlight %}

<h3 id="specs">
Running Specs</h3>

The specs for Thinking Sphinx require a database connection - and
currently will only talk to a database called `thinking_sphinx`. The
host defaults to `localhost`, the username `thinking_sphinx`, and no
password. If you want to customise these settings, create a YAML file
named `spec/fixtures/database.yml`. You can find a sample file at
`spec/fixtures/database.yml.default`.

{% highlight yaml %}  
host: localhost  
username: root  
password: secret  
{% endhighlight %}

Depending on which version of Sphinx you have installed, you will also
want to invoke the specs with the `VERSION` environment variable set.
Here’s an example:

{% highlight sh %}  
rake spec VERSION=0.9.9  
{% endhighlight %}

<h3 id="cucumber">
Running Cucumber Features</h3>

Thinking Sphinx’s Cucumber features require both a database, and port
9312 to run Sphinx on. The latter should take care of itself provided
you’re not using that port already. The former is managed by
`features/support/database.yml` (with an example file at
`features/support/database.example.yml`).

And again, just like with the specs, you’ll need to run the features
with a given version specified:

{% highlight sh %}  
rake features:mysql VERSION=0.9.9  
{% endhighlight %}

There are features tasks for both `mysql` and `postgresql`, and the base
task runs both, one after the other. You will need the same
authentication details for in each database system if you’re running the
feature set on both.

<h3 id="gems">
Writing Third-Party Gems</h3>

If you’re writing gems that hook into Thinking Sphinx, I highly
recommend you write specs that don’t interact with Sphinx or a database
if possible (via mocks and stubs), and then use Cucumber for integration
tests that interact with Sphinx.

For the latter, Thinking Sphinx provides a Cucumber World class to make
things pretty seamless. Firstly, your `features/support/env.rb` should
look something like the following:

{% highlight ruby %}  
require ‘rubygems’  
require ‘cucumber’  
require ‘spec/expectations’  
require ‘fileutils’  
require ‘active\_record’

$:.unshift File.dirname(*FILE*) + ‘/../../lib’

require ‘cucumber/thinking\_sphinx/internal\_world’

world = Cucumber::ThinkingSphinx::InternalWorld.new  
world.configure\_database

SphinxVersion = ENV\[‘VERSION’\] || ‘0.9.8’

require “thinking\_sphinx/\#{SphinxVersion}”  
require ‘path/to/thinking\_sphinx/extension’

world.setup  
{% endhighlight %}

This World expects four things:

-   Database migrations in `features/support/db/migrations`
-   Models in `features/support/models`
-   Ruby fixtures (for setting up model instances) in
    `features/support/db/fixtures`
-   Database configuration in `features/support/database.yml`

The default database settings are:

-   Adapter: `mysql`
-   Host: `localhost`
-   Database: `thinking_sphinx`
-   Username: `thinking_sphinx`

You can customise all of these settings via accessor methods on the
instance of the InternalWorld in your `env.rb` file.

I recommend looking at the [Delayed
Delta](http://github.com/pat/ts-delayed-delta/) library for inspiration.
