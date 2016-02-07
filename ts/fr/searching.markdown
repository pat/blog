---
layout: ts_fr
title: Searching
---


Searching
---------

Once you’ve [got an index set up](indexing.html) on your model, and have
[the Sphinx daemon running](rake_tasks.html), then you can start to
search, using a model named just that.

{% highlight ruby %}  
Article.search ‘pancakes’  
{% endhighlight %}

To focus a query on a specific field, you can use the **:conditions**
option - much like in ActiveRecord:

{% highlight ruby %}  
Article.search :conditions =&gt; {:subject =&gt; ‘pancakes’}  
{% endhighlight %}

You can combine both field-specific queries and generic queries too:

{% highlight ruby %}  
Article.search ‘pancakes’, :conditions =&gt; {:subject =&gt; ‘tasty’}  
{% endhighlight %}

Please keep in mind that Sphinx does not support SQL comparison
operators - it has its own query language. The **:conditions** option
must be a hash, with each key a field and each value a string.

Filters on attributes can be defined using a similar syntax, but using
the **:with** option.

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

### Pagination

Sphinx paginates search results by default. Indeed, there’s no way to
turn it off (but you can request really big pages should you wish). The
parameters for pagination in Thinking Sphinx are exactly the same as
[Will Paginate](http://github.com/mislav/will_paginate/tree/master):
**:page** and **:per\_page**.

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

