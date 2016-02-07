---
layout: ts_en
title: Common Questions and Issues
---


Common Questions and Issues
---------------------------

Depending on how you have Sphinx setup, or what database you’re using,
you might come across little issues and curiosities. Here’s a few to be
aware of.

-   [Editing the generated Sphinx configuration file](#editconf)
-   [Running multiple instances of Sphinx on one machine](#multiple)
-   [Viewing Result Weights](#weights)
-   [Wildcard Searching](#wildcards)
-   [Slow Indexing](#slow_indexing)
-   [MySQL and Large Fields](#mysql_large_fields)
-   [PostgreSQL with Manual Fields and Attributes](#postgresql)
-   [Delta Indexing Not Working](#deltas)
-   [Running Delta Indexing with Passenger](#passenger)
-   [Can only access the first thousand search results](#thousand_limit)
-   [Vendored Delayed Job, AfterCommit and Riddle](#vendored)
-   [Filtering on String Attributes](#string_filters)
-   [Models outside of `app/models`](#external_models)
-   [Using Thinking Sphinx with Bundler](#bundler)
-   [Mixing Ranged Filters and OR Logic](#range_or)
-   [Removing HTML from Excerpts](#escape_html)
-   [Using other Database Adapters](#other_adapters)
-   [Using OR Logic with Attribute Filters](#or_attributes)
-   [Catching Exceptions when Searching](#exceptions)
-   [Slow Requests (Especially in Development)](#slow-page-requests)
-   [Errors saying no fields are defined](#no-fields)

<h3 id="editconf">
Editing the generated Sphinx configuration file</h3>

In most situations, you won’t need to edit this file yourself, and can
rely on Thinking Sphinx to generate it reliably.

If you do want to customise the settings, you’ll find most options are
available to set via `config/sphinx.yml` - many are mentioned on the
[Advanced Sphinx Configuration page](advanced_config.html). For those
that aren’t mentioned on that page, you could still try setting it, and
there’s a fair chance it will work.

On the off chance that you actually do need to edit the file, make sure
you’re running the `thinking_sphinx:reindex` task instead of the normal
`thinking_sphinx:index` task - as the latter will always regenerate the
configuration file, overwriting your customisations.

<h3 id="multiple">
Running multiple instances of Sphinx on one machine</h3>

You can run as many Sphinx instances as you wish on one machine - but
each must be bound to a different port. You can do this via the
`config/sphinx.yml` file - just add a setting for the port for the
specific environment:

{% highlight yaml %}  
staging:  
 port: 9313  
{% endhighlight %}

Other options are documented on the [Advanced Sphinx Configuration
page](advanced_config.html).

<h3 id="weights">
Viewing Result Weights</h3>

To retrieve the weights/rankings of each search result, you can
enumerate through your matches using `each_with_weighting`:

{% highlight ruby %}  
results.each\_with\_weighting do |result, weight|  
 \# …  
end  
{% endhighlight %}

However, there is currently no clean way to get the weight of a specific
result without looping though the dataset.

<h3 id="wildcards">
Wildcard Searching</h3>

Sphinx can support wildcard searching (for example: Austr&lowast;), but
it is turned off by default. To enable it, you need to add two settings
to your config/sphinx.yml file:

{% highlight yaml %}  
development:  
 enable\_star: 1  
 min\_infix\_len: 1  
test:  
 enable\_star: 1  
 min\_infix\_len: 1  
production:  
 enable\_star: 1  
 min\_infix\_len: 1  
{% endhighlight %}

You can set the min\_infix\_len value to something higher if you don’t
need single characters with a wildcard being matched. This may be a
worthwhile fine-tuning, because the smaller the infixes are, the larger
your index files become.

Don’t forget to rebuild your Sphinx indexes after making this change.

{% highlight sh %}  
rake thinking\_sphinx:rebuild  
{% endhighlight %}

<h3 id="slow_indexing">
Slow Indexing</h3>

If Sphinx is taking a while to process all your records, there are a few
common reasons for this happening. Firstly, make sure you have database
indexes on any foreign key columns and any columns you filter or sort
by.

Secondly - are you using fixtures, or are there large gaps between
primary key values for your models? Sphinx isn’t set up to process
disparate IDs efficiently by default - and Rails’ fixtures have randomly
generated IDs, which are usually extremely large integers. To get around
this, you’ll need to set **sql\_range\_step** in your config/sphinx.yml
file for the appropriate environments:

{% highlight yaml %}  
development:  
 sql\_range\_step: 10000000  
{% endhighlight %}

<h3 id="mysql_large_fields">
MySQL and Large Fields</h3>

If you’ve got a field that is built off multiple values in one column -
ie: through a has\_many association - then you may hit MySQL’s default
limit for string concatenation: 1024 characters. You can increase the
[group\_concat\_max\_len](http://dev.mysql.com/doc/refman/5.1/en/server-system-variables.html#sysvar_group_concat_max_len)
value by adding the following to your define\_index block:

{% highlight rb %}  
define\_index do  
 \# …

set\_property :group\_concat\_max\_len =&gt; 8192  
end  
{% endhighlight %}

If these fields get particularly large though, then there’s another
setting you may need to set in your MySQL configuration:
[max\_allowed\_packet](http://dev.mysql.com/doc/refman/5.1/en/server-system-variables.html#sysvar_max_allowed_packet),
which has a default of sixteen megabytes. You can’t set this option via
Thinking Sphinx though (it’s a rare edge case).

<h3 id="postgresql">
PostgreSQL with Manual Fields and Attributes</h3>

If you’re using fields or attributes defined by strings (raw SQL), then
the columns used in them aren’t automatically included in the GROUP BY
clause of the generated SQL statement. To make sure the query is valid,
you will need to explicitly add these columns to the GROUP BY clause.

A common example is if you’re converting latitude and longitude columns
from degrees to radians via SQL.

{% highlight ruby %}  
define\_index do  
 \# …

has “RADIANS (latitude)”, :as =&gt; :latitude, :type =&gt; :float  
 has “RADIANS (longitude)”, :as =&gt; :longitude, :type =&gt; :float

group\_by “latitude”, “longitude”  
end  
{% endhighlight %}

<h3 id="deltas">
Delta Indexing Not Working</h3>

Often people find delta indexing isn’t working on their production
server. Sometimes, this is because Sphinx is running as one user on the
system, and the Rails/Merb application is being served as a different
user. Check your production.log and Apache/Nginx error log file for
mentions of permissions issues to confirm this.

Indexing for deltas is invoked by the web user, and so needs to have
access to the index files. The simplest way to ensure this is run all
Thinking Sphinx rake tasks by that web user.

If you’re still having issues, and you’re using Passenger, read the next
hint.

<h3 id="passenger">
Running Delta Indexing with Passenger</h3>

If you’re using Phusion Passenger on your production server, with delta
indexing on some models, a common issue people find is that their delta
indexes don’t get processed.

If it’s not a permissions issue (see the previous hint), another common
cause is because Passenger has it’s own PATH set up, and can’t execute
the Sphinx binaries (indexer and searchd) implicitly.

The way around this is to find out where your binaries are on the
server:

{% highlight sh %}  
which searchd  
{% endhighlight %}

And then set the bin\_path option in your config/sphinx.yml file for the
production environment:

{% highlight yaml %}  
production:  
 bin\_path: ‘/usr/local/bin’  
{% endhighlight %}

<h3 id="thousand_limit">
Can only access the first thousand search results</h3>

This is actually how Sphinx is supposed to behave. Have a read of the
[Large Result Sets section of the Advanced Configuration
page](advanced_config.html#large-result-sets) to see why, and how to
work around it if you really need to.

<h3 id="vendored">
Vendored Delayed Job, AfterCommit and Riddle</h3>

If you’ve still got Delayed Job vendored as part of Thinking Sphinx and
would rather use a more up-to-date version of the former, recent
releases of Thinking Sphinx do not have it included any longer.

As for AfterCommit and Riddle, while they are still included for plugin
installs, they’re no longer in the Thinking Sphinx gem (since 1.3.3).
Instead, they are considered dependencies, and will be installed as
separate gems.

<h3 id="string_filters">
Filtering on String Attributes</h3>

While you can have string columns as attributes in Sphinx, they aren’t
stored as strings. Instead, Sphinx figures out the alphabetical order,
and gives each string an integer value to make them useful for sorting.
However, this means it’s close to impossible to *filter* on these
attributes.

So, to get around this, there’s two options: firstly, use integer
attributes instead, if you possibly can. This works for small result
sets (for example: gender). Otherwise, you might want to consider
manually converting the string to a CRC integer value:

{% highlight ruby %}  
has “CRC32(category)”, :as =&gt; :category, :type =&gt; :integer  
{% endhighlight %}

This way, you can filter on it like so:

{% highlight ruby %}  
Article.search ‘pancakes’, :with =&gt; {  
 :category =&gt; ‘Ruby’.to\_crc32  
}  
{% endhighlight %}

Of course, this isn’t amazingly clean, but it will work quite well. You
should also take note that CRC32 encoding can have collisions, so it’s
not the perfect solution.

<h3 id="external_models">
Models outside of `app/models`</h3>

If you’re using plugins or other web frameworks (Radiant, Ramaze, etc)
that don’t always store their models in `app/models`, you can tell
Thinking Sphinx to look in other locations when building the
configuration file:

{% highlight ruby %}  
ThinkingSphinx::Configuration.instance.  
 model\_directories << "/path/to/models/dir"
{% endhighlight %}

By default, Thinking Sphinx will load all models in @app/models@ and @vendor/plugins/*/app/models@.

<h3 id="bundler">Using Thinking Sphinx with Bundler</h3>

If you’re using Thinking Sphinx with the gem manager Bundler, you will
need to set the `:require` option to thinking\_sphinx.

{% highlight ruby %}  
gem ‘thinking-sphinx’,  
 :version =&gt; ‘1.3.17’,  
 :require =&gt; ‘thinking\_sphinx’  
{% endhighlight %}

If this isn’t done, it can introduce issues with gem loading order and
script/console. And don’t forget that you will still need to explicitly
request the Thinking Sphinx tasks in your `Rakefile`:

{% highlight ruby %}  
require ‘thinking\_sphinx/tasks’  
{% endhighlight %}

<h3 id="range_or">
Mixing Ranged Filters and OR Logic</h3>

While Sphinx allows for querying with ranged filters on attributes, you
can’t have multiple filters joined by OR logic - all must match.

As a way around this, you might want to construct a SQL snippet which
returns specific values for each range interval, and then filter by an
array of values for the intervals you want. Check out [Tiago’s solution
on the Google
Group](http://groups.google.com/group/thinking-sphinx/msg/f022421e87a732bf).

This won’t suit all situations, of course - if you don’t have specific
range intervals, then you’re going to have to try something else.

<h3 id="escape_html">
Removing HTML from Excerpts</h3>

For a while, Thinking Sphinx auto-escaped excerpts. However, Sphinx
itself can remove HTML entities for indexing and excerpts, which is a
better way to approach this. So, you’ll want to add the following
setting to your `sphinx.yml` file:

{% highlight yaml %}  
html\_strip: true  
{% endhighlight %}

<h3 id="other_adapters">
Using other Database Adapters</h3>

If you’re using Thinking Sphinx in combination with a database adapter
that isn’t quite run-of-the-mill, you may need to add a snippet of code
to a Rails initialiser or equivalent (This is only available in versions
1.4.0 and 2.0.0 onwards, though).

Here’s an example that covers things for Octopus:

{% highlight ruby %}  
ThinkingSphinx.database\_adapter = lambda do |model|  
 case model.connection.config\[:adapter\]  
 when ‘mysql’, ‘mysql2’  
 :mysql  
 when ‘postgresql’  
 :postgresql  
 else  
 raise “You can only use Thinking Sphinx with MySQL or PostgreSQL”  
 end  
end  
{% endhighlight %}

Of course, `ThinkingSphinx.database_adapter` accepts a symbol as well,
if you just want to presume that you’ll always be using either MySQL or
PostgreSQL:

{% highlight ruby %}  
ThinkingSphinx.database\_adapter = :postgresql  
{% endhighlight %}

In most situations, though, you shouldn’t need to do this. Thinking
Sphinx understands the standard MySQL, PostgreSQL, MySQL2, MySQL Plus
and NullDB (as MySQL) adapters.

<h3 id="or_attributes">
Using OR Logic with Attribute Filters</h3>

It is possible to filter on attributes using OR logic - although you
need to be using Sphinx 0.9.9 or newer.

There’s two steps to it… firstly, you need to create a computed
attribute while searching, using Sphinx’s select option, and then filter
by that computed value. Here’s an example where we want to return all
publicly visible articles, as well as articles belonging to the user
with an ID of 5.

{% highlight ruby %}  
with\_display = “\*, IF (visible = 1 OR user\_id = 5, 1, 0) AS
display”  
Article.search ‘pancakes’,  
 :sphinx\_select =&gt; with\_display,  
 :with =&gt; {’display’ =&gt; 1}  
{% endhighlight %}

It’s important to note that you’ll want to include all existing
attribute values by default (that’s the `*` at the start of the select).
It’s quite similar to standard SQL syntax.

For further reading, I recommend Sphinx’s documentation on both [the
select
option](http://sphinxsearch.com/docs/manual-0.9.9.html#api-func-setselect)
and [expression
syntax](http://sphinxsearch.com/docs/manual-0.9.9.html#sort-expr).

<h3 id="exceptions">
Catching Exceptions when Searching</h3>

By default, Thinking Sphinx does not execute the search query until you
examine your search results - which is usually in the view. This is so
you can chain sphinx scopes without sending multiple (unnecessary)
queries to Sphinx.

However, this means that exceptions will be fired from within the view -
and most people put their exception handling in the controller. To force
exceptions to fire when you actually define the search, all you need to
do is to inform Thinking Sphinx that it should populate the results
immediately:

{% highlight ruby %}  
Article.search ‘pancakes’, :populate =&gt; true  
{% endhighlight %}

Obviously, if you’re chaining scopes together, make sure you add this at
the end with a final search call:

{% highlight ruby %}  
Article.published.search :populate =&gt; true  
{% endhighlight %}

<h3 id="slow-page-requests">
Slow Requests (Especially in Development)</h3>

If you’re finding a lot of requests are quite slow (particularly in your
local development environment), this could be because you have a lot of
models. Thinking Sphinx loads all models to determine which ones are
indexed by Sphinx (this is necessary to load search results), but you
can make things much faster by setting out [a list of indexed
models](/ts/en/advanced_config.html#indexed-models) in your
`config/sphinx.yml` file.

<h3 id="no-fields">
Errors saying no fields are defined</h3>

If you have defined fields (using the `indexes` method) but you’re
getting an error saying none are defined, it could be due to other gems
packaging custom (and perhaps broken) versions of the BlankSlate gem. To
get around this, add the proper BlankSlate gem to your Gemfile above
`thinking-sphinx`:

{% highlight ruby %}  
gem ‘blankslate’, ‘2.1.2.4’

1.  …  
    gem ‘thinking-sphinx’, ‘2.0.11’  
    {% endhighlight %}

