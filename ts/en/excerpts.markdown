---
layout: ts_en
title: Excerpts
---


Excerpts / Keyword Highlighting
-------------------------------

**Note: This feature is available in version 1.2 or later**

When displaying search results, sometimes you may wish to highlight the
query keywords in a record’s text. This can be done using Sphinx’s
excerpts feature.

Thinking Sphinx automatically adds a method called **excerpts** to each
search result, which can then query Sphinx for a specific column or
method for the object, and return the highlighted version.

An example, working with a set of Articles, where we request the
highlighted excerpts for the title and body:

{% highlight erb %}  
<% @articles.each do |article| %>

<div>
&lt;h3&gt;<%= article.excerpts.title %></h3>  
 &lt;div class=“date”&gt;<%= article.created_at.to_s(:short) %></div>  
 <%= textilize article.excerpts.body %>

</div>
<% end %>  
{% endhighlight %}

If you already have a method called **excerpts** on the search results,
Thinking Sphinx will not overwrite it. However, you will need to use a
slightly less elegant approach to generate the excerpted values:

{% highlight erb %}  
<% @articles.each do |article| %>

<div>
&lt;h3&gt;<%= @articles.excerpt_for(article.title) %></h3>  
 &lt;div class=“date”&gt;<%= article.created_at.to_s(:short) %></div>  
 <%= textilize @articles.excerpt_for(article.body) %>

</div>
<% end %>  
{% endhighlight %}

### Excerpts Settings

At this point in time, Thinking Sphinx does not have the ability to
customise the excerpts settings, but here are the defaults:

-   Keywords are wrapped in &lt;span class=“match”&gt;
-   Each chunk is separated by an ellipsis (…)
-   Each chunk has a maximum length of 256 characters (Sphinx will alter
    to ensure words aren’t cut in half).
-   Exact phrase matching is turned off by default.
-   Single passage matching is turned off by default.

Patches are welcome for ways to set these options to other values.
