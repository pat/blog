---
title: "A Concise Guide to Using Thinking Sphinx"
redirect_from: "/posts/a_concise_guide_to_using_thinking_sphinx/"
categories:
  - plugins
  - search
  - sphinx
  - ruby
  - rails
---
Okay, it’s well past time for the companion piece to [my Sphinx
Primer](http://freelancing-gods.com/posts/sphinx_a_primer) - let’s go
through the basic process of using Thinking Sphinx with Rails.

Just to recap: [Sphinx](http://sphinxsearch.com/) is a search engine
that indexes data, and then you can query it with search terms to find
out which documents are relevant. Why do you want to use it with Rails?
Because it saves having to write messy SQL, and it’s so damn fast.

(If you’re getting a feeling of deja-vu, then it’s probably because
you’ve read an [old post on this
blog](http://freelancing-gods.com/posts/a_thoughtful_sphinx) that dealt
with an old version of Thinking Sphinx. I’ve had a few requests for an
updated article, so this is it.)

### Installation

So: first step is to install Sphinx. This may be tricky on some systems
- but I’ve never had a problem with it with Mac OS X or Ubuntu. My
process is thus:

    curl -O http://sphinxsearch.com/downloads/sphinx-0.9.8-rc2.tar.gz
    tar zxvf sphinx-0.9.8-rc2.tar.gz
    cd sphinx-0.9.8-rc2
    ./configure
    make
    sudo make install

If you’re using Windows, you can just [grab the
binaries](http://sphinxsearch.com/downloads.html).

Once that’s taken care of, you then want to take your Rails app, and
install the plugin. If you’re running edge or 2.1, this is a piece of
cake:

    script/plugin install git://github.com/freelancing-god/thinking-sphinx.git

Otherwise, you’ve got a couple of options. The first is, if you have git
installed, just clone to your vendor/plugins directory:

    git clone git://github.com/freelancing-god/thinking-sphinx.git
      vendor/plugins/thinking-sphinx

If you’re not yet using git, then the easiest way is to download the tar
file of the code. Try the following:

    curl -L http://github.com/freelancing-god/thinking-sphinx/tarball/master
      -o thinking-sphinx.tar.gz
    tar -xvf thinking-sphinx.tar.gz -C vendor/plugins
    mv vendor/plugins/freelancing-god-thinking-sphinx* vendor/plugins/thinking-sphinx

Oh, and it’s worth noting: if you’re not using MySQL or PostgreSQL, then
you’re out of luck - Sphinx doesn’t talk to any other relational
databases.

### Configuration

Next step: let’s get a model or two indexed. It might be worth
refreshing your memory on what fields and attributes are for - can I
recommend [my Sphinx
article](http://freelancing-gods.com/posts/sphinx_a_primer) (because I’m
not at all biased)?

Ok, now let’s work with a simple Person model, and add a few fields:

    class Person < ActiveRecord::Base
      define_index do
        indexes [first_name, last_name], :as => :name
        indexes location
      end
    end

Nothing too scary - we’ve added two fields. The first is the first and
last names of a person combined to one field with the alias ‘name’. The
second is simply location.

Adding attributes is just as easy:

    define_index do
      # ...

      has birthday
    end

This attribute is the datetime value birthday (so you can now sort and
filter your results by birthdays).

### Managing Sphinx

We’ve set up a basic index - now what? We tell Sphinx to index the data,
and then we can start searching. Rake is our friend for this:

    rake thinking_sphinx:index
    rake thinking_sphinx:start

### Searching

Now for the fun stuff:

    Person.search "Melbourne"

Or with some sorting:

    Person.search "Melbourne", :order => :birthday

Or just people born within a 10 year window:

    Person.search "Melbourne", :with => {:birthday => 25.years.ago..15.years.ago}

If you want to keep certain search terms to specific fields, use
`:conditions`:

    Person.search :conditions => {:location => "Melbourne"}

Just remember: `:conditions` is for fields, `:with` is for attributes
(and `:without` for exclusive attribute filters).

### Change

Your data changes - but unfortunately, Sphinx doesn’t update your
indexes to match automatically. So there’s two things you need to do.
Firstly, run `rake thinking_sphinx:index` regularly (using cron or
something similar). ‘Regularly’ can mean whatever time frame you want -
weekly, daily, hourly.

The second step is optional, but it’s needed to have your indexes always
up to date. First, add a boolean column to your model, named ‘delta’,
and have it default to true. Then, tell your index to use that delta
field to keep track of changes:

    define_index do
      # ...

      set_property :delta => true
    end

Then you need to tell Sphinx about the updates:

    rake thinking_sphinx:stop
    rake thinking_sphinx:index
    rake thinking_sphinx:start

Once that’s done, a delta index will be created - which holds any recent
changes (since the last proper indexing), and gets re-indexed whenever a
model is edited or created. This doesn’t mean you can stop the regular
indexing, as that’s needed to keep delta indexes as small (and fast) as
possible.

### String Sorting

If you remember the details about fields and attributes, you’ll know
that you can’t sort by fields. Which is a pain, but there’s ways around
this - and it’s kept pretty damn easy in Thinking Sphinx. Let’s say we
wanted to make our `name` field sortable:

    define_index do
      indexes [first_name, last_name], :as => :name, :sortable => true

      # ...
    end

Re-index and restart Sphinx, and sorting by name will work.

How is this done? Thinking Sphinx creates an attribute under the hood,
called name\_sort, and uses that, as Sphinx is quite fine with sorting
by strings if they’re converted to ordinal values (which happens
automatically when they’re attributes).

### Pagination

Sphinx paginates automatically - in fact, there’s no way of turning that
off. But that’s okay… as long as you can use your will\_paginate helper,
right? Never fear, Thinking Sphinx plays nicely with will\_paginate, so
your views don’t need to change at all:

    <%= will_paginate @search_results %>

### Associations

Sometimes you’ll want data in your fields (or attributes) from
associations. This is a piece of cake:

    define_index do
      indexes photos.caption, :as => :captions
      indexes friends.photos.caption, :as => :friends_photos

      # ...
    end

Polymorphic associations are fine as well - but keep in mind, the more
complex your index fields and attributes, the slower it will be for
Sphinx to index (and you’ll definitely need some database indexes on
foreign key columns to help it stay as speedy as possible).

### Gotchas

In case things aren’t working, here’s some things to keep in mind:

-   Added an attribute, but can’t sort or filter by it? Have you
    reindexed and restarted Sphinx? It doesn’t automatically pick up
    these changes.
-   Sorting not working? If you’re specifying the attribute to sort by
    as a string, you’ll need to include the direction to sort by, just
    like with SQL: “birthday ASC”.
-   Using `name` or `id` columns in your fields or attributes? Make sure
    you specify them using symbols, as they’re core class methods
    in Ruby.

<!-- -->

    define_index do
      indexes :name

      # ...

      has photos(:id), :as => :photo_ids
    end

### And Next?

I realise this article is pretty light on details - but if you want more
information, the first stop should be the [extended usage
page](http://ts.freelancing-gods.com/usage.html) on the Thinking Sphinx
site, quickly followed by [the
documentation](http://ts.freelancing-gods.com/rdoc/). There’s also [an
email list](http://groups.google.com/group/thinking-sphinx/) to ask
questions on.

------------------------------------------------------------------------

<div class="comments">
<div class="comment-author">
Andrew Zielinski left a comment on 13 Jun, 2008:</div>

<div class="comment" markdown="1">
Nice Introduction to Thinking Sphinx. Thanks!

</div>
<div class="comment-author">
Benny left a comment on 13 Jun, 2008:</div>

<div class="comment" markdown="1">
Can you make a quick rundown why Thinking Sphinx is to be preferred
other other Sphinx helpers like Ultrasphinx ?

Which one has covered most of Sphinx’s features, etc.

</div>
<div class="comment-author">
<a href="http://marstononline.com">Marston A</a> left a comment on 13
Jun, 2008:</div>

<div class="comment" markdown="1">
Great article. I’m also curious if you’ve compared this to UltraSphinx
and how they stack up?

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 13 Jun,
2008:</div>

<div class="comment" markdown="1">
Andrew: no problems.

Benny and Marston: Ultrasphinx is more complex - which is useful if you
want to tweak Sphinx quite a bit. Thinking Sphinx’s goal is convention
over configuration - although you can set most things to whatever you
wish, it makes assumptions on file locations and such, so you can just
start using Sphinx as quickly as possible.

Thinking Sphinx also allows you to set all the settings you wish through
Ruby and YAML - so you don’t need to learn about the configuration
syntax of Sphinx if you don’t wish to.

Beyond that, there’s very little feature differences between the two
(indeed, both use my Sphinx API called Riddle to talk to Sphinx, so
there’s a level of commonality there).

As for other plugins - to the best of my knowledge, they’re not actively
maintained, and don’t use an API that’s inline with the latest version
of Sphinx.

</div>
<div class="comment-author">
Justin left a comment on 18 Jun, 2008:</div>

<div class="comment" markdown="1">
Currently using ferret but I think I will give this a try. Good info,
Thanks.

</div>
<div class="comment-author">
<a href="http://matthewbergman.com">Matthew Bergman</a> left a comment
on 25 Jun, 2008:</div>

<div class="comment" markdown="1">
Ultrasphinx might be more complex but I actually find it less useful in
terms of complex searches. Took me forever to index children due to an
error it has in concatenating.

</div>
<div class="comment-author">
Marco Bergantin left a comment on 26 Jun, 2008:</div>

<div class="comment" markdown="1">
Hi, cool work!  
just a tip about grouping with acts\_as\_taggable\_on\_steroids:  
Tagging.search\_with\_results(  
 :conditions=&gt;:taggable\_type=&gt;‘Site’},  
 :group\_by=&gt;‘tag\_ids’,  
 :group\_clause=&gt;’`count desc',
  :group_function=>:attr)
search_with_results == is the same than search but get directly the results Hash with `count
attribute.

</div>
<div class="comment-author">
Adrian left a comment on 14 Jul, 2008:</div>

<div class="comment" markdown="1">
Will Thinking Sphinx work with multiple databases in Rails, ala
hijacking connections on a per-request basis?

</div>
<div class="comment-author">
<a href="http://tech.bytefull.com">Ahsan</a> left a comment on 16 Jul,
2008:</div>

<div class="comment" markdown="1">
Hi there,

I have a model with first\_name and last\_name, but thinking\_sphinx
chokes on this:  
indexes \[first\_name, last\_name\], :as =&gt; :name, :sortable =&gt;
true

And raises this: “Cannot define a field with no columns. Maybe you are
trying to index a field with a reserved name (id, name). You can fix
this error by using a symbol rather than a bare name (:id instead of
id).”

I’m not sure why because my model doesn’t have any name attribute. I
also tried changing :as =&gt; :name to :as =&gt; :something\_else

Any ideas ?

</div>
<div class="comment-author">
<a href="http://tech.bytefull.com">Ahsan</a> left a comment on 16 Jul,
2008:</div>

<div class="comment" markdown="1">
Ok, I realized what I was doing wrong:

I was doing: indexes \[:first\_name, :last\_name\]

No need for symbols. Still, the error was misleading.

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 16 Jul,
2008:</div>

<div class="comment" markdown="1">
Ahsan, you’re right, it’s a misleading error message - and ideally, TS
should be fine with symbols anyway. Consider it a bug that needs fixing.

Thanks for the comments.

</div>
<div class="comment-author">
<a href="http://www.ninthspace.org">Chris</a> left a comment on 23 Jul,
2008:</div>

<div class="comment" markdown="1">
After much headbashing with Sphinx and acts\_as\_sphinx I decided to try
Thinking Sphinx instead. Glad I did. ’tis marvellous![]()

</div>
<div class="comment-author">
michael left a comment on 29 Jul, 2008:</div>

<div class="comment" markdown="1">
First of all… this plugin is great. i have tried it and it works very
easy.

How do you set the indexes and start/restart this on a server you dont
maintain yourself?

</div>
<div class="comment-author">
Peter Bengtson left a comment on 30 Jul, 2008:</div>

<div class="comment" markdown="1">
There is a bug in the configuration file generator - it always assumes
that Postgres listens on port 5432. You need to change the following:

config = <<-SOURCE

source #{model.indexes.first.name}_#{index}_core
{
type     = #{db_adapter}
sql_host = #{database_conf[:host] || "localhost"}
sql_port = #{database_conf[:port]}
sql_user = #{database_conf[:username]}
sql_pass = #{database_conf[:password]}
sql_db   = #{database_conf[:database]}

sql_query_pre    = #{charset_type == "utf-8" && adapter == :mysql ? "SET NAMES utf8" : ""}
#{"sql_query_pre    = SET SESSION group_concat_max_len = #{@options[:group_concat_max_len]}" if @options[:group_concat_max_len]}
sql_query_pre    = #{to_sql_query_pre}
sql_query        = #{to_sql.gsub(/\n/, ' ')}
sql_query_range  = #{to_sql_query_range}
sql_query_info   = #{to_sql_query_info}
#{attr_sources}
}
      SOURCE

That is, it needs a sql_port line, as added above.
</div>

<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 30 Jul,
2008:</div>

<div class="comment" markdown="1">
Michael: if you don’t have shell access, I’ve no idea… in that sort of
situation, you might be out of luck, unfortunately.

Peter: Thanks for that! I’ll add it in when I get the chance. Cheers.

</div>
<div class="comment-author">
Kristof left a comment on 31 Jul, 2008:</div>

<div class="comment" markdown="1">
Pat,

Many thanks for your great work! Great solution for full-text search and
absolutely my preferred way of accessing Sphinx.

I have a little question regarding indexing polymorphic associations.
Can you shine a little light on how to specify these?

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 1 Aug,
2008:</div>

<div class="comment" markdown="1">
Hi Kristof

You can use polymorphic associations just as you would normal
associations, when defining fields and indexes.

The main thing to keep in mind: TS looks at the database’s existing
records to figure out what models are used in the polymorphic joins (and
thus what columns are sourced from where). So make sure you have indexes
on your `_type` columns (else indexing gets **really** slow).

Feel free to let me know if you have any troubles (or post to [the
list](http://groups.google.com/group/thinking-sphinx)).

</div>
<div class="comment-author">
Brian Johnson left a comment on 3 Aug, 2008:</div>

<div class="comment" markdown="1">
I need to split my model into multiple indices by country. I have tried
everything I can think of and have posted on the Sphinx mailing list,
but for my needs, that seems to be the only viable solution. Is there a
way to configure multiple indices, each with their own delta and then
search by main/delta pairs. Lets say we have
Products\_US\_Main/Products\_US\_Delta and
Products\_MX\_Main/Products\_MX\_Delta and I want to search only in the
MX indices. I have been looking through the code and I saw a
index\_weight field, but it’s not clear to me how you would select an
index or set of indices, or even if you can declare more than one index
for a model and name it. Thanks.

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 4 Aug,
2008:</div>

<div class="comment" markdown="1">
Hi Brian

Unfortunately Thinking Sphinx doesn’t work like that. Not sure if
Ultrasphinx does either… with some hacking, it might be possible for TS
to do this, though - define\_index can be called multiple times,
technically, but not sure how well it’d work - and you’d want to loop
through calls for each country.

Otherwise, you might be best writing your own solution, and perhaps use
Riddle for talking to Sphinx?

</div>
<div class="comment-author">
<a href="http://www.craigambrose.com">Craig Ambrose</a> left a comment
on 9 Aug, 2008:</div>

<div class="comment" markdown="1">
Hi Pat,

Do you have any info on the performance implications of delta indexing?
I’ve got delta indexing turned on for some of my models, such as
Product, and it seems to be slowing down edits to these objects pretty
significantly. In particular it’s a bit of a pain the way it updates the
index even if I only change data on the model which is not actually
indexed by sphinx. Failing that, some of my batch operations which
operate on many Product records trigger a lot of small index updates. Do
you think it would be better if I take the delta indexing off this and
simple update the entire index more frequently? I think that some other
sphinx plugins use delta indexing, but the delta index update is still
not done within the mongrel process. Ie, every two minutes refresh the
delta index.

got any suggestions?

cheers,

Craig

</div>
<div class="comment-author">
Brian Johnson left a comment on 9 Aug, 2008:</div>

<div class="comment" markdown="1">
I am using Ultrasphinx right now, primarily because of the
association\_sql capabilities that give me more advanced control over
the index queries, but I thought it would be easier to add that to
Thinking Sphinx than to add multiple indexes to Ultrasphinx due do the
way indexes are generated in Ultrasphinx. If it’s complicated in both, I
may take a second look at Ultrasphinx because I’ve already implemented
it in my application.

</div>
<div class="comment-author">
Lang Riley left a comment on 11 Aug, 2008:</div>

<div class="comment" markdown="1">
Long time user and contributor to ultrasphinx and just switched to
thinking sphinx. Your code is clean and well organized. Looks like it
will be much easier to do more advanced sphinx things, like search
within results to n depth, aka guided navigation on facets with
multi-values. Thanks![]()

</div>
<div class="comment-author">
Justin left a comment on 12 Aug, 2008:</div>

<div class="comment" markdown="1">
great plug in, much better than acts\_as\_ferret. One thing though, i
have some products that have a lot of different sizes and i need to
group those products but i’ve tired with now success. Could someone tell
me how. Thanks

</div>
<div class="comment-author">
justin left a comment on 12 Aug, 2008:</div>

<div class="comment" markdown="1">
ner mind..

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 14 Aug,
2008:</div>

<div class="comment" markdown="1">
Craig: there is plans to shift delta indexing out to some messaging
service. Not sure when that’ll happen though. For bulk updates, [see
this
solution](http://groups.google.com/group/thinking-sphinx/browse_thread/thread/0e9889c3083e9bd0).

Brian: Not quite sure what you’re asking. The SQL for indexes are
generated automatically by Thinking Sphinx, using ActiveRecord’s
underlying classes.

Lang: Great to hear - although we are lacking some of those features in
TS (at least, the core branch - a few people have their own facets
implementations figured out).

Justin: I assume you got the problem sorted?

Don’t forget about [the mailing
list](http://groups.google.com/group/thinking-sphinx) for any other
questions.

</div>
<div class="comment-author">
Dev Singh left a comment on 13 Sep, 2008:</div>

<div class="comment" markdown="1">
I am trying to setup wildcard matching in TS.

Have created a sphinx.yml file with the following:

development:  
 enable-star: true  
 min\_prefix:\_len: 4  
 min\_infix:\_len: 4

(also tried various variations with allow\_star: true)

The development.sphinx.conf file was generated successfully  
Howevr I am unable to get searches like:

User.search “pat\*”

to work. It returns an empty array. Is this syntax incorrect? is not the
“\*” what we use for a wildcard match for the sphinx query?

Using Sphinx latest 0.9.8

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 13 Sep,
2008:</div>

<div class="comment" markdown="1">
Hi Dev

What you’ve done is correct - although I’m not certain if you can have
both min prefix and min infix set. Have you restarted the Sphinx daemon?

</div>
<div class="comment-author">
franee left a comment on 16 Sep, 2008:</div>

<div class="comment" markdown="1">
Hi,

Is there a way to search by specifying specific models to be searched?

thanks!

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 16 Sep,
2008:</div>

<div class="comment" markdown="1">
franee: If you want to use just a single model, `ModelClass.search`. If
you want to search across several specific models, use
`ThinkingSphinx::Search.search "text", :classes => [ModelClassOne, ModelClassTwo]`

</div>
<div class="comment-author">
John-Paul left a comment on 14 Jan, 2009:</div>

<div class="comment" markdown="1">
Hi

does thinking sphinx work easily with has\_many type relationships? For
example, novels with many authors, and many publishers and many editions
etc.

My app has a lot of join tables simply because of the nature of the data
model. I’ve managed to get this working in acts\_as\_ferret, just
curious if this degree of data model complexity is workable in TS.

thanks in advance

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 15 Jan,
2009:</div>

<div class="comment" markdown="1">
Hi John-Paul

Thinking Sphinx is fine with any ActiveRecord relationships - just drill
down in your define\_index block like so (assuming model is Novel):

      indexes authors.name, :as => :authors
      indexes publishers.name, :as => :publishers

If you need to drill down deeper, to the associations of associations,
you can do that too.

</div>
<div class="comment-author">
Nilesh left a comment on 7 Mar, 2009:</div>

<div class="comment" markdown="1">
Hi Pat,

Thanks for the wonderful plug in & the article.  
I have a similar problem as John-Paul, searching on a Forum. I have
defined indexes on the Forum model only, but want results from topics &
posts as well.  
So I have the following in the Forum model.

define\_index do  
 indexes title  
 indexes description  
 indexes topics.title, :as =&gt; :topic\_title  
 indexes topics.posts.title, :as =&gt; :post\_title  
 indexes topics.posts.comment, :as =&gt; :comment  
end

And in my controllers I use Forum.search search\_string

So even if a topic or post matches, I get the result as a Forum object
only. But I wish to list the exact topic/post that matched. How can I
attain this ?  
If I do result.topics I get all the topics in that particular forum.
Note that I have to index/search on multiple columns from the
association model.

Thanks,  
Nilesh

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 8 Mar,
2009:</div>

<div class="comment" markdown="1">
Hi Nilesh

Do you want post results? Or forum results? Personally, I’d expect
posts, so I’d put the index definition within the Post model, and then
use the associations to get information from the topic and forum into
there as well. Perhaps something like the following:

    define_index do
      indexes comment, title
      indexes topic.title, :as => :topic
      indexes topic.forum.title, :as => :forum
      indexes topic.forum.description, :as => :forum_description
    end

</div>
<div class="comment-author">
Nilesh left a comment on 8 Mar, 2009:</div>

<div class="comment" markdown="1">
Thanks Pat,

The solution above does not return me results for just Topic/Forum. It
searches and returns Posts only. I mean it can be that just topic title
could match the search\_string or a forum title, forum description could
match the search\_string and no post actually matches. Can I get such
results from TS ? Or do you suggest using the following:

ThinkingSphinx::Search.search search\_string, :classes =&gt;
\[ModelClassOne, ModelClassTwo\]

But the above could give me duplicate forums/topics. I mean I could get
the same Forum, Topic in result from the searches on different
Model(Once from the direct match on them and once from the Posts
matched). What is a better solution, as I need to match & show posts,
topics, forums ?

Thanks,  
Nilesh.

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 8 Mar,
2009:</div>

<div class="comment" markdown="1">
Hmm, okay, it’s a tricky problem. What you could do, is have indexes on
all three models, and then search across them all, but group on a common
id - so, if you want one result per forum, make sure each model has the
attribute forum\_id (so Forum will have `has :id, :as => :forum_id`,
Topic `has forum_id` and Post `has topic.forum_id, :as => :forum_id`).
Perhaps the better response is one result per topic?
`has topics(:id), :as => :topic_id`, `has :id, :as => :topic_id` and
`has topic_id` respectively.

For grouping in searching:

    ThinkingSphinx::Search.search "whatever", :classes => [Forum, Topic, Post], :group_function => :attr, :group_by => "forum_id"

You’ll probably want to put some weighting on certain fields too… but
they’ll probably need to be commonly named across all three indexes (I’m
not sure though).

If this solution isn’t quite perfect, let’s continue this discussion on
[the google group](http://groups.google.com/group/thinking-sphinx) so
others can benefit from it as well.

</div>
<div class="comment-author">
engine left a comment on 9 Mar, 2009:</div>

<div class="comment" markdown="1">
hi,  
thanks for this great plugin! everything worked as expected in just a
few minutes :D  
unfortunately i want to achive something i did not find in the ts
docu:  
i want to match the very first character of a field.  
is there a way to configure ts to generate following addition to the
sphinx.conf:

sql\_query = SELECT … …, ORD (UPPER(table.field)) AS init\_ord FROM …  
sql\_attr\_uint = init\_ord

i posted a more detailed description in the sphinx forum (2009-03-08
16:11:23 post \#8 by engine)

thanks in advance for your help!  
one more thanks for ts!  
engine

</div>
<div class="comment-author">
e left a comment on 9 Mar, 2009:</div>

<div class="comment" markdown="1">
sorry, i forgot to post the link to the more detailed post:  
http://sphinxsearch.com/forum/view.html?id=3107&new=1  
engine

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 10 Mar,
2009:</div>

<div class="comment" markdown="1">
Sure, what you can do is create a manual attribute:

    has "ORD(UPPER(title))", :as => :ord_int

And then you can filter using `:with => {:ord_int => 65..90}`, using
your example from the Sphinx forum.

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 10 Mar,
2009:</div>

<div class="comment" markdown="1">
Oh, I forgot one thing - you’ll need an explicit type declaration for
the attribute.

    has "ORD(UPPER(title))", :as => :ord_int, :type => :integer

</div>
<div class="comment-author">
engine left a comment on 10 Mar, 2009:</div>

<div class="comment" markdown="1">
omg, i didn’t expect that it is so easy!  
everything works perfect now!  
maybe you shoud add this example to
http://ts.freelancing-gods.com/usage.html

thanks a lot for your help![]()!  
engine

</div>
<div class="comment-author">
frag left a comment on 11 Mar, 2009:</div>

<div class="comment" markdown="1">
Thanks! for the awesome plugin.  
<code>  
define\_index do  
 has “ORD (UPPER(title))”, :as =&gt; :ord\_int, :type =&gt; :integer  
end  
</code>  
this works well.

</div>
<div class="comment-author">
rajesh left a comment on 11 Mar, 2009:</div>

<div class="comment" markdown="1">
Hi Pat,

Thanks for the Wonderfull plugin.  
I need to filter search results on the bases of ‘OR’ condition.I have
indexed Event model like :

Event—has many—EventUsers


    define_index do
        indexes event.summary
        has is_private, created_by
        has event_users(:id), :as => :event_ids
        has event_users.user_id, :as => :event_user_id
        has event_users.status, :as => :event_user_status 
    end   
     

Now, I need to search somthing like

      Event.search "something" 

with following conditions

     
       
      :conditions => ['(events.starts_at >= ? and events.starts_at <= ?) AND ((events.is_private = 0 OR (events_users.user_id = ? AND events_users.status = ?)) or (events.created_by = ?))"]
       

I tried it with :condtions =&gt; {} and :with =&gt; {} but both
generates the query with ‘AND’.

what is the way to implement above conditions?

Thanks,  
Rajesh

</div>
<div class="comment-author">
<a href="http://www.sequoia-cg.com">Bryan</a> left a comment on 11 Mar,
2009:</div>

<div class="comment" markdown="1">
I have something weird going on. Some search criteria that i run in
rails returns an error finding an id that is way off (too high) for a
record. Any idea what might be causing this? I restarted the process and
reindexed already. Thanx

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 23 Mar,
2009:</div>

<div class="comment" markdown="1">
Rajesh: I’ve responded to your post on the list - hopefully that’s
helpful.

Bryan: I recommend you ask that question on [the
list](http://groups.google.com/group/thinking-sphinx) if you haven’t
already - but at a guess, are you using fixtures in development?

</div>
<div class="comment-author">
Daniel left a comment on 18 Jun, 2009:</div>

<div class="comment" markdown="1">
Hi Pat,

you say: “add a boolean column to your model, named ‘delta’, and have it
default to false”

on the page at http://freelancing-god.github.com/ts/en/deltas.html your
migration adds the delta field with “true by default” ( “add\_column
:articles, :delta, :boolean, :default =&gt; true, :null =&gt; false”)

those two are conflicting, which is true?

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 18 Jun,
2009:</div>

<div class="comment" markdown="1">
Hi Daniel

The documentation is newer, so that’s what I recommend now (true). It
doesn’t actually matter though, because the TS code will be setting the
value to true whenever a new instance is created anyway.

But because new values should be considered part of the delta, having
‘true’ as the default makes a bit more sense.

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 18 Jun,
2009:</div>

<div class="comment" markdown="1">
Just updated this blog post to have a default of true as well, to avoid
any future confusion :)

</div>
<div class="comment-author">
<a href="http://sandip.sosblog.com">sandip</a> left a comment on 25 Jun,
2009:</div>

<div class="comment" markdown="1">
Hello All,

I wanted to implement sphinx search.  
I have following models.

Blog

1.  post model has column “channel\_feature\_id”  
    has\_many :posts, :foreign\_key =&gt; “channel\_feature\_id”  
    ———  
    Post  
     \# Indexes for thinking sphinx  
     define\_index do  
     indexes title  
     indexes abstract  
     indexes body  
     \#indexes comments.body, :as =&gt; :comment\_content  
     \# OPTIONAL: keeps search index uptodate  
     \# First, add a boolean column to your model, named ‘delta’, and
    have it default to true.  
     \# Then uncomment following line.  
     \#set\_property :delta =&gt; true  
     end  
     belongs\_to :blog  
     has\_many :comments  
     \# GET published posts  
     named\_scope :published, :conditions =&gt; \[ ‘published = ?’, true
    \]  
    ———  
    Comment  
    belongs\_to :post

------------------------------------------------------------------------

In my search action i have

blog.posts.published.search ( params\[:search\] )

i dont know what is wrong  
i am getting following error

Missing Attribute for Foreign Key channel\_feature\_id

Thanks,  
Sandip

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 26 Jun,
2009:</div>

<div class="comment" markdown="1">
Hi Sandip

You may want to continue this discussion on the [google
group](http://groups.google.com/group/thinking-sphinx/), since it
handles long messages a bit better than this blog.

The issue is that you’re searching on Posts, filtered by a specific Blog
- and so need an attribute for the foreign key. Try adding
`has channel_feature_id` to your Post `define_index` block.

</div>
<div class="comment-author">
<a href="http://mousse.net/nony">nony</a> left a comment on 14 Aug,
2009:</div>

<div class="comment" markdown="1">
Hi,

very great plugin up and runnig in no time, indexing/searching is really
very fast and it can do every advanced thing i can think of (and many i
don’t understand ;)

One thing i googled for ~2 hours until i found it was the
:matching\_mode option for searches.

I suggest mentioning that on the ‘Searching’ page or somewhere a
newcomer would look. (I didn’t even know I was searching for ‘matching
mode’ or ‘extended query’ most of the time ;)

Thanks for the great work![]()

</div>
<div class="comment-author">
georgia left a comment on 28 Jan, 2010:</div>

<div class="comment" markdown="1">
Could somebody tell me what needs to be put in the view to display the
search and the results????

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 28 Jan,
2010:</div>

<div class="comment" markdown="1">
Hi Georgia

It’s just like what you would do with results from a call to `find`:

    <% @articles.each do |article| %>
      <%= article.name %>
    <% end %>

</div>
<div class="comment-author">
Ritu left a comment on 29 Jan, 2010:</div>

<div class="comment" markdown="1">
Hi,  
First appreciation for the great plugin.

Second a question. Is there any way with which I can create index
specific to table name and not model names.

For some reason my model uses multiple table and based on some setting
it changes the table name for that model. Now I want to index all these
tables and search in the one referenced only. Is there any way in TS
that I can try to do it.

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 30 Jan,
2010:</div>

<div class="comment" markdown="1">
Hi Ritu

In the most recent versions of Thinking Sphinx, you can name your
indexes to whatever you want: `define_index('custom') do ...`

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 30 Jan,
2010:</div>

<div class="comment" markdown="1">
If you need something more complex then that, then I recommend
continuing the conversation on [the google
group](http://groups.google.com/group/thinking-sphinx/)

</div>
<div class="comment-author">
Yan left a comment on 1 Apr, 2011:</div>

<div class="comment" markdown="1">
Hi, I was trying to do the indexing and it gave me the following error
message:  
Cannot automatically map attribute DOB in Patient to an  
equivalent Sphinx type (integer, float, boolean, datetime, string as
ordinal).  
You could try to explicitly convert the column’s value in your
define\_index  
block:  
has “CAST (column AS INT)”, :type =&gt; :integer, :as =&gt; :column

DOB is just a date data type. Do you have any idea what might causing
it?

Thank you!

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 1 Apr,
2011:</div>

<div class="comment" markdown="1">
Hmm, date columns should be automatically set to datetime. What version
of TS are you using?

Also, the immediate workaround: <code>has DOB, :type =&gt;
:datetime</code>

</div>
<div class="comment-author">
Yan left a comment on 4 Apr, 2011:</div>

<div class="comment" markdown="1">
I am using 1.3.16  
I am kind of limited to this version because I cannot find a easy way to
upgrade ruby on red hat enterprise.  
But What I was trying to do is to copy a working rails app that is using
TS for another account , I also copies the database so that the other
person can learn and working on the copy of the app. The original app is
working without any problem.

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 4 Apr,
2011:</div>

<div class="comment" markdown="1">
Hi Yan

Did setting the type explicitly (the last part of my previous comment)
help?

Otherwise, let’s continue this conversation on the [Google
Group](http://groups.google.com/group/thinking-sphinx)

</div>
<div class="comment-author">
Yan left a comment on 8 Apr, 2011:</div>

<div class="comment" markdown="1">
Thank you.  
rake thinking\_sphinx:index worked. But When I tried to start the
sphinx, it gave me another error that it cannot start searchd daemon. I
will post this in the google group.

</div>
<div class="comment-author">
annu left a comment on 26 Aug, 2011:</div>

<div class="comment" markdown="1">
how to get the result of search aft entering the text in the textfield
and clickin on search button i am usin sphinx and thinking sphinx  
i am done with following code  
i wann to search for the data from my articles db  
 in my searchcontroller  
def create  
 @articles = Article.search params\[:search\]  
 end  
in my articles model  
define\_index do  
 indexes name, :sortable =&gt; true  
 indexes description  
 indexes title, :sortable =&gt; true

end  
 def self.search(search)  
 ThinkingSphinx::Search  
 end  
 in view/search/index.html.erb  
<%= form_tag  do %>

<p>
<%= text_field_tag :search, params[:search] %>  
<%= submit_tag "search", :name => nil %&gt;

</p>
<% end %>

</div>
</div>

