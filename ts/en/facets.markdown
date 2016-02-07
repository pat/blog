---
layout: ts_en
title: Facets
---


Faceted Searching
-----------------

Facet Searches are search summaries - they provide a breakdown of result
counts for each of the defined categories/facets.

### Defining Facets

You define facets inside the **define\_index** method, within your
model. To specify that a field or attribute should be considered a
facet, explicitly label it using the **:facet** symbol.

{% highlight ruby %}  
define\_index do  
 \# …  
 indexes author.name, :as =&gt; :author, :facet =&gt; true

\# …  
 has category\_id, :facet =&gt; true  
end  
{% endhighlight %}

You *cannot* use custom SQL statements as string facet sources. Thinking
Sphinx is unable to interpret the SQL within the context of the model,
and strings can’t be stored as strings when they are attributes in
Sphinx.

Even if you define your facet as a field, Thinking Sphinx duplicates it
into an attribute, because facets are essentially grouped searches, and
grouping can only be done with attributes.

### Querying Facets

Facets are available through the facets class method on all ActiveRecord
models that have Sphinx indexes, and are returned as a subclass of Hash.

{% highlight ruby %}  
Article.facets \# =&gt;  
{  
 :author =&gt; {  
 “Sherlock Holmes” =&gt; 3,  
 “John Watson” =&gt; 10  
 },  
 :category\_id =&gt; {  
 12 =&gt; 4,  
 42 =&gt; 7,  
 47 =&gt; 2  
 }  
}  
{% endhighlight %}

The facets method accepts the same options as the **search** method.

{% highlight ruby %}  
Article.facets ‘pancakes’  
Article.facets :conditions =&gt; {:author =&gt; ‘John Watson’}  
Artcile.facets :with =&gt; {:category\_id =&gt; 12}  
{% endhighlight %}

You can also explicitly request just certain facets:

{% highlight ruby %}  
Article.facets :facets =&gt; \[:author\]  
{% endhighlight %}

To retrieve the ActiveRecord object results based on a selected
facet(s), you can use the `for` method on a facet search result. When
using the **for** method, Thinking Sphinx will automatically CRC any
string values and use their respective `field_name_facet` attribute.

{% highlight ruby %}

1.  Facets for all articles matching ‘detection’  
    `facets   = Article.facets('detection')
    # All 'detection' articles with author 'Sherlock Holmes'
    `articles = @facets.for(:author =&gt; ‘Sherlock Holmes’)  
    {% endhighlight %}

If you call `for` without any arguments, then all the matching search
results for the initial facet query are returned.

{% highlight ruby %}  
`facets   = Article.facets('pancakes')
`articles = @facets.for  
{% endhighlight %}

### Global Facets

Faceted searches can be made across all indexed models, using the same
arguments.

{% highlight ruby %}  
ThinkingSphinx.facets ‘pancakes’  
{% endhighlight %}

By default, Thinking Sphinx does not request *all* possible facets, only
those common to all models. If you don’t have any of your own facets,
then this will just be the class facet, providing a summary of the
matches per model.

{% highlight ruby %}  
ThinkingSphinx.facets ‘pancakes’ \# =&gt;  
{  
 :class =&gt; {  
 ‘Article’ =&gt; 13,  
 ‘User’ =&gt; 3,  
 ‘Recipe’ =&gt; 23  
 }  
}  
{% endhighlight %}

To disable the class facet, just set :class\_facet to false.

{% highlight ruby %}  
ThinkingSphinx.facets ‘pancakes’, :class\_facet =&gt; false  
{% endhighlight %}

And if you want absolutely every facet defined to be returned, whether
or not they exist in all indexed models, set :all\_facets to true.

{% highlight ruby %}  
ThinkingSphinx.facets ‘pancakes’, :all\_facets =&gt; true  
{% endhighlight %}

### Displaying Facets

To get you started, here is a basic example displaying the facet options
in a view:

{% highlight erb %}  
<% @facets.each do |facet, facet_options| %>  
 &lt;h5&gt;<%= facet %></h5>

<ul>
<% facet_options.each do |option, count| %>  
 &lt;li&gt;<%= link_to "#{option} (#{count})",
      :params => {facet =&gt; option, :page =&gt; 1} %&gt;</li>  
 <% end %>

</ul>
<% end %>  
{% endhighlight %}

Thinking Sphinx does not sort facet results. If this is what you’d
prefer, then one option is to use Ruby’s **sort** or **sort\_by**
methods. Keep in mind you will then get arrays of two values (the facet
value, and the facet count), instead of a hash key/value pair.

{% highlight ruby %}  
`facets[:author].sort
# Sort by strings to avoid exceptions
`facets\[:author\].sort\_by { |a| a\[0\].to\_s }  
{% endhighlight %}

### Facets Internals

When you define fields as facets, then an attribute with the same
columns is created with the suffix `_facet`. If the field is a string
(which is the case in most situations), then the value is converted to a
CRC32 integer.

This CRC32 value is necessary as Sphinx currently doesn’t support true
string attributes, and thus we need a value to filter and group by when
determining the facet results.

In the above examples, we have the author’s name as a facet. This means
there’s an author\_facet attribute, which you could filter on with the
following query:

{% highlight ruby %}  
Article.search :with =&gt; {:author\_facet =&gt; ‘John
Watson’.to\_crc32}  
{% endhighlight %}

This means you can step around the `facets` and `for` calls to get
results for specific facet arguments using `search` (again, using
earlier examples):

{% highlight ruby %}

1.  all ‘detection’ articles with author ‘Sherlock Holmes’  
    Article.search ‘detection’,  
     :with =&gt; {:author\_facet =&gt; ‘Sherlock Holmes’.to\_crc32}  
    {% endhighlight %}

