---
layout: ts_en
title: Searching
---


Searching
---------

-   [Basic Searching](#basic)
-   [Field Conditions](#conditions)
-   [Attribute Filters](#filters)
-   [Application-Wide Search](#global)
-   [Pagination](#pagination)
-   [Match Modes](#matchmodes)
-   [Ranking Modes](#ranking)
-   [Sorting](#sorting)
-   [Field Weights](#fieldweights)
-   [Search Results Information](#results)
-   [Grouping/Clustering](#grouping)
-   [Searching for Object Ids](#ids)
-   [Search Counts](#counts)
-   [Avoiding Nil Results](#nils)
-   [Automatic Wildcards](#star)
-   [Errors](#errors)
-   [Advanced Options](#advanced)

<h3 id="basic">
Basic Searching</h3>

Once you’ve [got an index set up](indexing.html) on your model, and have
[the Sphinx daemon running](rake_tasks.html), then you can start to
search, using a model named just that.

{% highlight ruby %}  
Article.search ‘pancakes’  
{% endhighlight %}

Please note that Sphinx paginates search results, and the default page
size is 20. You can find more information further down in the
[pagination](#pagination) section.

<h3 id="conditions">
Field Conditions</h3>

To focus a query on a specific field, you can use the `:conditions`
option - much like in ActiveRecord:

{% highlight ruby %}  
Article.search :conditions =&gt; {:subject =&gt; ‘pancakes’}  
{% endhighlight %}

You can combine both field-specific queries and generic queries too:

{% highlight ruby %}  
Article.search ‘pancakes’, :conditions =&gt; {:subject =&gt; ‘tasty’}  
{% endhighlight %}

Please keep in mind that Sphinx does not support SQL comparison
operators - it has its own query language. The `:conditions` option must
be a hash, with each key a field and each value a string.

<h3 id="filters">
Attribute Filters</h3>

Filters on attributes can be defined using a similar syntax, but using
the `:with` option.

{% highlight ruby %}  
Article.search ‘pancakes’, :with =&gt; {:author\_id =&gt; @pat.id}  
{% endhighlight %}

Filters have the advantage over focusing on specific fields in that they
accept arrays and ranges:

{% highlight ruby %}  
Article.search ‘pancakes’, :with =&gt; {  
 :created\_at =&gt; 1.week.ago..Time.now,  
 :author\_id =&gt; @fab\_four.collect { |author| author.id }  
}  
{% endhighlight %}

And of course, you can mix and match global terms, field-specific terms,
and filters:

{% highlight ruby %}  
Article.search ‘pancakes’,  
 :conditions =&gt; {:subject =&gt; ‘tasty’},  
 :with =&gt; {:created\_at =&gt; 1.week.ago..Time.now}  
{% endhighlight %}

If you wish to exclude specific attribute values, then you can specify
them using `:without`:

{% highlight ruby %}  
Article.search ‘pancakes’,  
 :without =&gt; {:user\_id =&gt; current\_user.id}  
{% endhighlight %}

For matching multiple values in a multi-value attribute, `:with` doesn’t
quite do what you want. Give `:with_all` a try instead:

{% highlight ruby %}  
Article.search ‘pancakes’,  
 :with\_all =&gt; {:tag\_ids =&gt; @tags.collect(&:id)}  
{% endhighlight %}

<h3 id="global">
Application-Wide Search</h3>

You can use all the same syntax to search across all indexed models in
your application:

{% highlight ruby %}  
ThinkingSphinx.search ‘pancakes’  
{% endhighlight %}

If you’re using a version of Thinking Sphinx prior to 1.2, you will need
to use a slightly deeper namespaced method:
`ThinkingSphinx::Search.search`.

This search will return all objects that match, no matter what model
they are from, ordered by relevance (unless you specify a custom order
clause, of course). Don’t expect references to attributes and fields to
work perfectly if they don’t exist in all the models.

If you want to limit global searches to a few specific models, you can
do so with the `:classes` option:

{% highlight ruby %}  
ThinkingSphinx.search ‘pancakes’, :classes =&gt; \[Article, Comment\]  
{% endhighlight %}

<h3 id="pagination">
Pagination</h3>

Sphinx paginates search results by default. Indeed, there’s no way to
turn it off (but you can request really big pages should you wish). The
parameters for pagination in Thinking Sphinx are exactly the same as
[Will Paginate](http://github.com/mislav/will_paginate/tree/master):
`:page` and `:per_page`.

{% highlight ruby %}  
Article.search ‘pancakes’, :page =&gt; params\[:page\], :per\_page =&gt;
42  
{% endhighlight %}

The output of search results can be used with Will Paginate’s view
helper as well, just to keep things nice and easy.

{% highlight ruby %}

1.  in the controller:  
    @articles = Article.search ‘pancakes’

<!-- -->

1.  in the view:  
    will\_paginate @articles  
    {% endhighlight %}

<h3 id="matchmodes">
Match Modes</h3>

Sphinx has several different ways of matching the given search keywords,
which can be set on a per-query basis using the `:match_mode` option.

{% highlight ruby %}  
Article.search ‘pancakes waffles’, :match\_mode =&gt; :any  
{% endhighlight %}

Most are pretty self-explanatory, but here’s a quick guide. If you need
more detail, check out [Sphinx’s own
documentation](http://www.sphinxsearch.com/docs/current.html#matching-modes).

#### `:all`

This is the default for Thinking Sphinx, and requires a document to have
every given word somewhere in its fields.

#### `:any`

This will return documents that include at least one of the keywords in
their fields.

#### `:phrase`

This matches all given words together in one place, in the same order.
It’s just the same as wrapping a Google search in quotes.

#### `:boolean`

This allows you to use boolean logic with your keywords. & is AND, | is
OR, and both - and ! function as NOTs. You can group logic within
parentheses.

{% highlight ruby %}  
Article.search ‘pancakes & waffles’, :match\_mode =&gt; :boolean  
Article.search ‘pancakes | waffles’, :match\_mode =&gt; :boolean  
Article.search ‘pancakes !waffles’, :match\_mode =&gt; :boolean  
Article.search ‘( pancakes topping ) | waffles’,  
 :match\_mode =&gt; :boolean  
{% endhighlight %}

Keep in mind that ANDs are used implicitly if no logic is given, and you
can’t query with just a NOT - Sphinx needs at least one keyword to
match.

#### `:extended`

Extended combines boolean searching with phrase searching,
[field-specific searching](#conditions), field position limits,
proximity searching, quorum matching, strict order operator, exact form
modifiers (since 0.9.9rc1) and field-start and field-end modifiers
(since 0.9.9rc2).

I highly recommend having a look at [Sphinx’s syntax
examples](http://www.sphinxsearch.com/docs/current.html#extended-syntax).
Also keep in mind that if you use the `:conditions` option, then this
match mode will be used automatically.

#### `:extended2`

This is much like the normal extended mode, but with some quirks that
Sphinx’s documentation doesn’t cover. Generally, if you don’t know you
want to use it, don’t worry about using it.

#### `fullscan`

This match mode ignores all keywords, and just pays attention to
filters, sorting and grouping.

<h3 id="ranking">
Ranking Modes</h3>

Sphinx also has a few different ranking modes (again, [the Sphinx
documentation](http://www.sphinxsearch.com/docs/current.html#api-func-setrankingmode)
is the best source of information on these). They can be set using the
`:rank_mode` option:

{% highlight ruby %}  
Article.search “pancakes”, :rank\_mode =&gt; :bm25  
{% endhighlight %}

#### `:proximity_bm25`

The default ranking mode, which combines both phrase proximity and BM25
ranking (see below).

#### `:bm25`

A statistical ranking mode, similar to most other full-text search
engines.

#### `:none`

No ranking - every result has a weight of 1.

#### `:wordcount` (since 0.9.9rc1)

Ranks results purely on the number of times the keywords are found in a
document. Field weights are taken into factor.

#### `:proximity` (since 0.9.9rc1)

Ranks documents by raw proximity value.

#### `:match_any` (since 0.9.9rc1)

Returns rankings calculated in the same way as a match mode of `:any`.

#### `:fieldmask` (since 0.9.9rc2)

Returns rankings as a 32-bit mask with the N-th bit corresponding to the
N-th field, numbering from 0. The bit will only be set when any of the
keywords match the respective field. If you want to know which fields
match your search for each document, this is the only way.

<h3 id="sorting">
Sorting</h3>

By default, Sphinx sorts by how relevant it believes the documents to be
to the given search keywords. However, you can also sort by attributes
(and fields flagged as sortable), as well as time segments or custom
mathematical expressions.

Attribute sorting defaults to ascending order:

{% highlight ruby %}  
Article.search “pancakes”, :order =&gt; :created\_at  
{% endhighlight %}

If you want to switch the direction to descending, use the `:sort_mode`
option:

{% highlight ruby %}  
Article.search “pancakes”, :order =&gt; :created\_at,  
 :sort\_mode =&gt; :desc  
{% endhighlight %}

If you want to use multiple attributes, or Sphinx’s ranking scores, then
you’ll need to use the `:extended` sort mode. This will be set by
default if you pass in a string to `:order`, but you can set it manually
if you wish. This syntax is pretty much the same as SQL, and directions
(ASC and DESC) are required for each attribute.

{% highlight ruby %}  
Article.search “pancakes”, :sort\_mode =&gt; :extended,  
 :order =&gt; “created\_at DESC, @relevance DESC”  
{% endhighlight %}

As well as using any attributes and sortable fields here, you can also
use Sphinx’s internal attributes (prefixed with @). These are:

-   `id (The match's document id)
    * `weight, `rank or `relevance (The match’s ranking weight)
-   @random (Returns results in random order)

#### Expression Sorting

If you’re hoping to make your ranking algorithm a bit more complex, then
you can break out the arithmetic and use Sphinx’s expression sort mode:

{% highlight ruby %}  
Article.search “pancakes”, :sort\_mode =&gt; :expr,  
 :order =&gt; “@weight \* views \* karma”  
{% endhighlight %}

[Reading the Sphinx
documentation](http://www.sphinxsearch.com/docs/current.html#sorting-modes)
is required if you really want to understand the power and options
around this sorting method.

#### Time Segment Sorting

Sphinx also has a curious sort mode, `:time_segments`. This breaks down
a given timestamp/datetime attribute into the following segments, and
then the matches within the segments are sorted by their ranking.

-   Last Hour
-   Last Day
-   Last Week
-   Last Month
-   Last 3 Months
-   Everything else

You can’t change the segment points - these are fixed by Sphinx. To use
this sort method, you need to specify it as well as the attribute to use
as a reference point:

{% highlight ruby %}  
Article.search “pancakes”, :sort\_mode =&gt; :time\_segments,  
 :sort\_by =&gt; :updated\_at  
{% endhighlight %}

<h3 id="fieldweights">
Field Weights</h3>

Sphinx has the ability to weight fields with differing levels of
importance. You can set this using the `:field_weights` option in your
searches:

{% highlight ruby %}  
Article.search “pancakes”, :field\_weights =&gt; {  
 :subject =&gt; 10,  
 :tags =&gt; 6,  
 :content =&gt; 3  
}  
{% endhighlight %}

You don’t need to specify all fields - any not given values are kept at
the default weighting of 1.

If you’d like the same custom weightings to apply to all searches, you
can set the values in the `define_index` block:

{% highlight ruby %}  
set\_property :field\_weights =&gt; {  
 :subject =&gt; 10,  
 :tags =&gt; 6,  
 :content =&gt; 3  
}  
{% endhighlight %}

<h3 id="results">
Search Results Information</h3>

If you’re building your own pagination output, then you can find out the
statistics of your search using the following accessors:

notextile.. {% highlight ruby %}  
`articles = Article.search 'pancakes'
# Number of matches in Sphinx
`articles.total\_entries

1.  Number of pages available  
    `articles.total_pages
    # Current page index
    `articles.current\_page
2.  Number of results per page  
    @articles.per\_page  
    {% endhighlight %}

<h3 id="grouping">
Grouping / Clustering</h3>

Sphinx allows you group search records that share a common attribute,
which can be useful when you want to show aggregated collections. For
example, if you have a set of posts and they are all part of a category
and have a category\_id, you could group your results by category id and
show a set of all the categories matched by your search, as well as all
the posts. You can read more about it in the [official Sphinx
documentation](http://sphinxsearch.com/docs/current.html#clustering).

For grouping to work, you need to pass in the `:group_by` parameter and
a `:group_function` parameter.

Searching posts, for example:

{% highlight ruby %}  
Post.search ‘syrup’,  
 :group\_by =&gt; ‘category\_id’,  
 :group\_function =&gt; :attr  
{% endhighlight %}

By default, this will return your Post objects, but one per
category\_id. If you want to sort by how many posts each category
contains, you can pass in :group\_clause :

{% highlight ruby %}  
Post.search ‘syrup’,  
 :group\_by =&gt; ‘category\_id’,  
 :group\_function =&gt; :attr,  
 :group\_clause =&gt; “@count desc”  
{% endhighlight %}

You can also group results by date. Given you have a date column in your
index:

{% highlight ruby %}  
class Post < ActiveRecord::Base
  define_index
    ...
    has :created_at
  end
end
{% endhighlight %}

Then you can group search results by that date field:

{% highlight ruby %}
Post.search 'treacle',
  :group_by       => ‘created\_at’,  
 :group\_function =&gt; :day  
{% endhighlight %}

You can use the following date types:

-   `:day`
-   `:week`
-   `:month`
-   `:year`

Once you have the grouped results, you can enumerate by each result
along with the group value, the number of objects that matched that
group value, or both, using the following methods respectively:

{% highlight ruby %}  
posts.each\_with\_groupby { |post, group| }  
posts.each\_with\_count { |post, count| }  
posts.each\_with\_groupby\_and\_count { |post, group, count| }  
{% endhighlight %}

<h3 id="ids">
Searching for Object Ids</h3>

If you would like just the primary key values returned, instead of
instances of ActiveRecord objects, you can use all the same search
options in a call to `search_for_ids` instead.

{% highlight ruby %}  
Article.search\_for\_ids ‘pancakes’  
ThinkingSphinx.search\_for\_ids ‘pancakes’  
{% endhighlight %}

<h3 id="counts">
Search Counts</h3>

If you just want the number of matches, instead of the matched objects
themselves, then you can use the `search_count` method (which accepts
all the same arguments as a normal `search` call). If you’re searching
globally, then there is an alias to the `ThinkingSphinx.count` method.

{% highlight ruby %}  
Article.search\_count ‘pancakes’  
ThinkingSphinx.count ‘pancakes’  
ThinkingSphinx.search\_count ‘pancakes’  
{% endhighlight %}

<h3 id="nils">
Avoiding Nil Results</h3>

Thinking Sphinx tries its hardest to make sure Sphinx knows when records
are deleted, but sometimes stale objects slip through the gaps. To get
around this, Thinking Sphinx has the option of retrying searches.

To enable this, you can set `:retry_stale` to true, and Thinking Sphinx
will make up to three tries at retrieving a full result set that has no
nil values. If you want to change the number of tries, set
`:retry_stale` to an integer.

And obviously, this can be quite an expensive call (as it instantiates
objects each time), but it provides a better end result in some
situations.

{% highlight ruby %}  
Article.search ‘pancakes’, :retry\_stale =&gt; true  
Article.search ‘pancakes’, :retry\_stale =&gt; 1  
{% endhighlight %}

<h3 id="star">
Automatic Wildcards</h3>

If you’d like your search keywords to be wildcards for every search, you
can use the `:star` option, which automatically prepends and appends
wildcard stars to each word.

{% highlight ruby %}  
Article.search ‘pancakes waffles’, :star =&gt; true

1.  =&gt; becomes ‘**pancakes** **waffles**’  
    {% endhighlight %}

<h3 id="errors">
Errors</h3>

At times, Sphinx will return no results, but sometimes that’s because
there was a problem with the actual query provided. When this happens,
Sphinx includes the error message in the results.

You can access errors with `error` and test for errors with `error?`.

If an error is encountered, ThinkingSphinx will log it and then raise a
`ThinkingSphinx::SphinxError` exception. You can tell ThinkingSphinx to
ignore errors (though it will still log them) by passing in
`:ignore_errors => true` or setting the property in your index with
`set_property :ignore_errors => true`.

For example:

{% highlight ruby %}  
r = Article.search ‘@doesntexist foo’, :match\_mode =&gt; :extended,  
 :ignore\_errors =&gt; true  
r.error? \# =&gt; true  
{% endhighlight %}

Sphinx also issues warnings that you can test for with `warning?` and
inspect with `warning`. No exception is raised on warnings.

<h3 id="advanced">
Advanced Options</h3>

Thinking Sphinx also accepts the following advanced Sphinx arguments:

-   [`:id_range`](http://www.sphinxsearch.com/docs/current.html#api-func-setidrange)
-   [`:cut_off`](http://www.sphinxsearch.com/docs/current.html#api-func-setlimits)
-   [`:retry_count` and
    `:retry_delay`](http://www.sphinxsearch.com/docs/current.html#api-func-setretries)
-   [`:max_query_time`](http://www.sphinxsearch.com/docs/current.html#api-func-setmaxquerytime)

Additionally, Thinking Sphinx accepts `:comment`, as the search’s
comment (which is printed in the query log), and `:sql_order`, which is
passed through to the SQL query to instantiate the ActiveRecord objects.
The latter might be useful if Sphinx’s data isn’t quite accurate for
sorting (as can be the case with ordinal attributes).

One other option - to avoid lazily loading search results and make sure
Thinking Sphinx processes the search query immediately, is the
`:populate` option:

{% highlight ruby %}  
Article.search ‘pancakes’, :populate =&gt; true  
{% endhighlight %}

This is particularly useful to ensure exceptions are raised where you
expect them to.
