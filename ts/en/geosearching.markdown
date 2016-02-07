---
layout: ts_en
title: Geo-searching
---


Geo-Searching
-------------

One of the neat features of Sphinx is the ability to sort and filter by
a calculated geographical distance, from latitude and longitude values.
It’s quite easy to get set up, as well.

### Setting up the Indexes

Firstly, you’ll need to be storing latitude and longitude values as
attributes for each relevant document. So, in your `define_index` block,
you’ll need something like this, if you’ve already got the columns in
your model:

{% highlight ruby %}  
has latitude, longitude  
{% endhighlight %}

Keep in mind, though, that Sphinx needs these values to be **floats**,
and tracking positions by **radians** instead of degrees. If this isn’t
the case in your own database (which isn’t a surprise - most people
store the values as degrees), then you’ll need to manually convert
columns for the attributes:

{% highlight ruby %}  
has “RADIANS (latitude)”, :as =&gt; :latitude, :type =&gt; :float  
has “RADIANS (longitude)”, :as =&gt; :longitude, :type =&gt; :float  
{% endhighlight %}

Once this is done, you’ll need to rebuild your Sphinx indexes:

{% highlight sh %}  
rake thinking\_sphinx:rebuild  
{% endhighlight %}

You can name your attributes to be whatever you like - Thinking Sphinx
will automatically use them if they’re called latitude, longitude, lat,
lon or lng. If you’re using something a little less standard, then you
can set up your index to still use the attributes automatically:

{% highlight ruby %}  
define\_index do  
 \# …

set\_property :latitude\_attr =&gt; :updown,  
 :longitude\_attr =&gt; :leftright  
end  
{% endhighlight %}

### Searching

Once your indexes are set up, then you can begin searching. You need to
make sure you’re doing two things:

-   Provide a geographical reference point
-   Filter or sort by the calculated distance

For the first, you can provide an array of two arguments (latitude and
longitude, again in **radians**) to the `:geo` option. For the second,
you’ll need to refer to Sphinx’s internal attribute `@geodist` in a
filter and/or a sort argument.

{% highlight ruby %}

1.  Searching for places within 10km  
    Place.search “pancakes”, :geo =&gt; \[`lat, `lng\],  
     :with =&gt; {“`geodist" => 0.0..10_000.0}
    # Searching for places sorted by closest first
    Place.search "pancakes", :geo => [`lat, `lng],
      :order => "`geodist ASC, @relevance DESC”  
    {% endhighlight %}

If you do not provide any reference to `@geodist`, then the lat/lng
values will be ignored by Sphinx.

**Don’t forget:** Sphinx expects the latitude and longitude values to be
in radians - so you will probably need to convert the values when
searching.

### Displaying Results

There’s two ways to access the calculated distance. You can either
enumerate through the collection using `each_with_geodist`:

{% highlight rhtml %}  
<% @places.each_with_geodist do |place, distance| %>  
 &lt;li&gt;<%= place.name %>, <%= distance %></li>  
<% end %>  
{% endhighlight %}

Or, you can access the distance as part of the `sphinx_attributes`
collection:

{% highlight rhtml %}  
<% @places.each do |place| %>

<li>
<%= place.name %>,  
 <%= place.sphinx_attributes['@geodist'] %>

</li>
<% end %>  
{% endhighlight %}

It’s worth noting that the distance is in metres - so those stuck on the
Imperial system (Americans, that’s you), you might want to convert to
less archaic measurements.
