---
layout: ts_en
title: Testing
---


Testing with Thinking Sphinx
----------------------------

Before you get caught up in the specifics of testing Thinking Sphinx
using certain tools, it’s worth noting that no matter what the approach,
you’ll need to turn off transactional fixtures and index your data after
creating the appropriate records - otherwise you won’t get any search
results.

Also: make sure you have your test environment using a different port
number in `config/sphinx.yml` (which you may need to create if you
haven’t already). If this isn’t done, then you won’t be able to run
Sphinx in your development environment *and* your tests at the same time
(as they’ll both want to use the same port for Sphinx).

{% highlight yaml %}  
test:  
 port: 9313  
{% endhighlight %}

<ul>
<li>
<a href="#unit_tests">Unit Tests and Specs</a></li>

<li>
<a href="#cucumber">Cucumber</a></li>

<li>
<a href="#functional">Rails Functional and Integration Tests</a></li>

</ul>
<h3 id="unit_tests">
Unit Tests and Specs</h3>

It’s recommended you stub out any search calls, as Thinking Sphinx
should ideally only be used in integration testing (whether that be via
Cucumber or other methods).

<h3 id="cucumber">
Cucumber</h3>

As of version **1.3.2**, Thinking Sphinx has a helper object to make
combining Thinking Sphinx and Cucumber quite easy. You’ll need to add
the following two lines to your `features/support/env.rb` file:

{% highlight ruby %}  
require ‘cucumber/thinking\_sphinx/external\_world’  
Cucumber::ThinkingSphinx::ExternalWorld.new  
{% endhighlight %}

Don’t forget, you also *need* to turn transactional fixtures off. This
can be done on a global level in your `features/support/env.rb` file:

{% highlight ruby %}  
Cucumber::Rails::World.use\_transactional\_fixtures = false  
{% endhighlight %}

Or, you can tag either an entire feature or single scenarios with the
`@no-txn` tag:

{% highlight gherkin %}  
@no-txn  
Feature: Searching for articles  
{% endhighlight %}

The reason for this is that while ActiveRecord can run all its
operations within a single transaction, Sphinx doesn’t have access to
that, and so indexing will not include your transaction’s changes.

The added complication to this is that you’ll probably want to clear all
the data from your database between scenarios. This can be done within
the `Before` block, in one of your steps files (see below). Another
option is Ben Mabey’s [Database
Cleaner](http://github.com/bmabey/database_cleaner) library - and make
sure you use the truncation strategy.

{% highlight ruby %}  
Before do  
 \# Add your own models here instead.  
 \[Article, User\].each do |model|  
 model.delete\_all  
 end  
end  
{% endhighlight %}

Once this is all set up, then Sphinx will automatically index and start
the daemon when you run your features - but only once at the very
beginning, not for every scenario (as that could be quite slow).

To re-index during specific scenarios, I recommend adding steps
something like the following (to be called after preparing your model
data, but before Webrat browses the application):

{% highlight ruby %}  
Given ‘the Sphinx indexes are updated’ do  
 \# Update all indexes  
 ThinkingSphinx::Test.index  
 sleep(0.25) \# Wait for Sphinx to catch up  
end

Given ‘the Sphinx indexes for articles are updated’ do  
 \# Update specific indexes  
 ThinkingSphinx::Test.index ‘article\_core’, ‘article\_delta’  
 sleep(0.25) \# Wait for Sphinx to catch up  
end  
{% endhighlight %}

Delta indexes (if you’re using the default approach) will automatically
update just like they do in a normal application environment.

Any suggestions to improve this workflow are very much welcome.

<h3 id="functional">
Rails Functional and Integration Tests</h3>

In much the same way, Thinking Sphinx can be used in traditional
functional and integration tests. You’ll want to add the following lines
to your **test\_helper.rb** file:

{% highlight ruby %}  
require ‘thinking\_sphinx/test’  
ThinkingSphinx::Test.init  
{% endhighlight %}

You can turn off transactional features on a per-test basis within the
test class definition:

{% highlight ruby %}  
class SearchControllerTest  
 self.use\_transactional\_fixtures = false

\# …  
end  
{% endhighlight %}

To actually have Sphinx running, you have a few options…

If you want it running constantly for *all* of your tests, you can call
`start_with_autostop` in your `test_helper.rb` file:

{% highlight ruby %}  
ThinkingSphinx::Test.start\_with\_autostop  
{% endhighlight %}

However, you probably don’t want Sphinx running for your unit tests, and
so it’s recommended you just start and stop Sphinx as required.
`ThinkingSphinx::Test` has methods named `start` and `stop` for that
very purpose:

{% highlight ruby %}  
test “Searching for Articles” do  
 ThinkingSphinx::Test.start

get :index  
 assert \[@article\], assigns\[:articles\]

ThinkingSphinx::Test.stop  
end  
{% endhighlight %}

You can also wrap the code that needs Sphinx in a block called by
`ThinkingSphinx::Test.run`, which will start up and stop Sphinx either
side of the block:

{% highlight ruby %}  
test “Searching for Articles” do  
 ThinkingSphinx::Test.run do  
 get :index  
 assert \[@article\], assigns\[:articles\]  
 end  
end  
{% endhighlight %}

If you need to manually process indexes, just use the `index` method,
which defaults to all indexes unless you pass in specific names.

{% highlight ruby %}  
ThinkingSphinx::Test.index \# all indexes  
ThinkingSphinx::Test.index ‘article\_core’, ‘article\_delta’  
{% endhighlight %}
