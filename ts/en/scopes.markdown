---
layout: ts_en
title: Sphinx Scopes
---


Sphinx Scopes
-------------

**Note: This feature is available in version 1.2 or later**

One of the popular features of ActiveRecord is named scopes. You can try
using them with searches, but they will not impact search results, just
the SQL queries used to gather the ActiveRecord objects - Sphinx itself
does not use SQL for querying.

However, Thinking Sphinx now has sphinx scopes, which work in pretty
much the same manner.

### Adding Scopes

To add a scope to the model, use the `sphinx_scope` method. This should
be called within the class definition, not the define\_index block.

{% highlight ruby %}  
class Article < ActiveRecord::Base
  # associations

  define_index do
    # index definition
  end

  sphinx_scope(:latest_first) { 
    {:order => ‘created\_at DESC, @relevance DESC’}  
 }  
 sphinx\_scope(:by\_name) { |name|  
 {:conditions =&gt; {:name =&gt; name}}  
 }  
 \# Here’s an example using do/end instead of {} blocks.  
 sphinx\_scope(:by\_point) do |lat, lng|  
 {:geo =&gt; \[lat, lng\]}  
 end

\# …  
end  
{% endhighlight %}

Just like `named_scope`, you can use arguments if you need to.

### Using Scopes

Once you have set up your scopes, you can use them on your model, just
like you would use ActiveRecord’s named scopes.

{% highlight ruby %}  
`articles = Article.latest_first.search 'pancakes'
`articles = Article.latest\_first.by\_name(‘Puck’).search ‘pancakes’  
{% endhighlight %}

The search call is optional, if you don’t actually have any extra
arguments to pass in.

{% highlight ruby %}  
@articles = Article.latest\_first.by\_name(‘Puck’)  
{% endhighlight %}

Feel free to add to the chain at any point - Thinking Sphinx won’t
populate the search results until you actually need them.

{% highlight ruby %}  
`articles = Article.latest_first
`articles = @articles.by\_name(params\[:name\]) if params\[:name\]  
{% endhighlight %}

### Default Scopes

The `default_sphinx_scope` method allows a sphinx scope to always be
used when searching a model. This can be useful if all searches on a
model require the scope is used.

{% highlight ruby %}  
class Article < ActiveRecord::Base
  # associations

  define_index do
    # index definition
  end

  sphinx_scope(:latest_first) { 
    {:order => ‘created\_at DESC, @relevance DESC’}  
 }

default\_sphinx\_scope :latest\_first

end  
{% endhighlight %}
