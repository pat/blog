---
layout: ts_en
title: Indexing
---


Indexing your Models
--------------------

-   [Basic Indexing](#basic)
-   [Fields](#fields)
-   [Attributes](#attributes)
-   [Conditions and Groupings](#conditions)
-   [Sanitizing SQL](#sql)
-   [Multiple Indices](#multiple)
-   [Processing your Index](#processing)

<h3 id="basic">
Basic Indexing</h3>

Everything to set up the indexes for your models goes in the
**define\_index** method, within your model. Don’t forget to place this
block *below* your associations and any `accepts_nested_attributes_for`
calls, otherwise any references to them for fields and attributes will
not work.

{% highlight ruby %}  
class Article < ActiveRecord::Base
  # ...

  define_index do
    indexes subject, :sortable => true  
 indexes content  
 indexes author(:name), :as =&gt; :author, :sortable =&gt; true

has author\_id, created\_at, updated\_at  
 end

\# …  
end  
{% endhighlight %}

<h3 id="fields">
Fields</h3>

The `indexes` method adds one (or many) fields, by referencing the
model’s column names. **You cannot reference model methods** - Sphinx
talks directly to your database, and Ruby doesn’t get loaded at this
point.

{% highlight ruby %}  
indexes content  
{% endhighlight %}

Keep in mind that if you’re referencing a column that shares its name
with a core Ruby method (such as id, name or type), then you’ll need to
specify it using a symbol.

{% highlight ruby %}  
indexes :name  
{% endhighlight %}

You don’t need to keep the same names as the database, though. Use the
`:as` option to signify an alias.

{% highlight ruby %}  
indexes content, :as =&gt; :post  
{% endhighlight %}

You can also flag fields as being sortable.

{% highlight ruby %}  
indexes subject, :sortable =&gt; true  
{% endhighlight %}

Use the **:facet** option to signify a facet.

{% highlight ruby %}  
indexes authors.name, :as =&gt; :author, :facet =&gt; true  
{% endhighlight %}

If there are associations in your model, you can drill down through them
to access other columns. Explicit aliases are *required* when doing
this.

{% highlight ruby %}  
indexes author(:name), :as =&gt; :author  
indexes author.location, :as =&gt; :author\_location  
{% endhighlight %}

There may be times when a normal column value isn’t exactly what you’re
after, so you can also define your indexes as raw SQL:

notextile.. {% highlight ruby %}  
indexes “LOWER (first\_name)”, :as =&gt; :first\_name, :sortable =&gt;
true  
{% endhighlight %}

Again, in this situation, an explicit alias is required.

<h3 id="attributes">
Attributes</h3>

The **has** method adds one (or many) attributes, and just like the
**indexes** method, it requires references to the model’s column names.

{% highlight ruby %}  
has author\_id  
{% endhighlight %}

The syntax is very similar to setting up fields. You can set aliases,
and drill down into associations. You don’t ever need to label an
attribute as **:sortable** though - in Sphinx, all attributes can be
used for sorting.

Also, just like fields, if you’re referring to a reserved method of Ruby
(such as id, name or type), you need to use a symbol (which, when
dealing with associations, is within a method call).

{% highlight ruby %}  
has :id, :as =&gt; :article\_id  
has tags(:id), :as =&gt; :tag\_ids  
{% endhighlight %}

<h3 id="conditions">
Conditions and Groupings</h3>

Because the index is translated to SQL, you may want to add some custom
conditions or groupings manually - and for that, you’ll want the `where`
and `group_by` methods:

{% highlight ruby %}  
define\_index do  
 \# …

where “status = ‘active’”

group\_by “user\_id”  
end  
{% endhighlight %}

<h3 id="sql">
Sanitizing SQL</h3>

As previously mentioned, your index definition results in SQL from the
indexes, the attributes, conditions and groupings, etc. With this in
mind, it may be useful to simplify your index.

One way would be to use something like `ActiveRecord::Base.sanitize_sql`
to generate the required SQL for you. For example:

{% highlight ruby %}  
define\_index do  
 \# …

where sanitize\_sql(\[“published”, true\])  
end  
{% endhighlight %}

This will produce the expected `WHERE published = 1` for MySQL.

<h3 id="multiple">
Multiple Indices</h3>

If you want more than one index defined for a given model, just insert
more `define_index` calls - but make sure you give every index a name,
and have the same attributes defined in all indices.

{% highlight ruby %}  
define\_index ‘article\_foo’ do  
 \# index definition  
end

define\_index ‘article\_bar’ do  
 \# index definition  
end  
{% endhighlight %}

<h3 id="processing">
Processing your Index</h3>

Once you’ve got your index set up just how you like it, you can run [the
rake task](rake_tasks.html) to get Sphinx to process the data.

{% highlight sh %}  
rake thinking\_sphinx:index  
{% endhighlight %}

As each model is processed, you will see a message much like the one
below. It is just a warning, not an error. Everything will work fine.

{% highlight sh %}  
distributed index ‘article’ can not be directly indexed; skipping.  
{% endhighlight %}

However, if you have made structural changes to your index (which is
anything except adding new data into the database tables), you’ll need
to stop Sphinx, re-index, and then re-start Sphinx - which can be done
through a single rake call.

{% highlight sh %}  
rake thinking\_sphinx:rebuild  
{% endhighlight %}
