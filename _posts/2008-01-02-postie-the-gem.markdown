---
title: "Postie - The Gem"
redirect_from: "/posts/postie_the_gem/"
categories:
  - australia
  - postcodes
  - api
  - gems
  - ruby
---
An addition to [auspostie.com](http://auspostie.com), prompted by [Dr
Nic’s](http://drnicwilliams.com/) suggestion in the comments of the
earlier blog post - the [postie gem](http://postie.rubyforge.org). It
allows easy parsing of Postie search results, and also provides a
command-line tool for searching.

By suburb:

    postie Brunswick

By postcode:

    postie 3070

To install:

    sudo gem install postie

To use within your own ruby code:

    require 'postie'

    Postie::Locality.find("Melbourne")

Again, extremely simple, but just makes access to the data that little
bit easier.

Now, what would be really cool is a Quicksilver plugin that queries the
API. Any volunteers to code that up?

------------------------------------------------------------------------

<div class="comments">
<div class="comment-author">
<a href="http://rhnh.net">Xavier Shay</a> left a comment on 3 Jan,
2008:</div>

<div class="comment" markdown="1">
~/Code/redbubble-trunk&gt; postie ‘North Fitzroy’  
/opt/local/lib/ruby/1.8/uri/common.rb:436:in \`split’: bad
URI (is not URI?): http://auspostie.com/North Fitzroy.xml
(URI::InvalidURIError)  
 from /opt/local/lib/ruby/1.8/uri/common.rb:485:in \`parse’  
 from /opt/local/lib/ruby/1.8/open-uri.rb:29:in \`open’  
 from
/opt/local/lib/ruby/gems/1.8/gems/postie-1.0.0/lib/postie/locality.rb:16:in
\`find’  
 from /opt/local/lib/ruby/gems/1.8/gems/postie-1.0.0/bin/postie:13  
 from /opt/local/bin/postie:19:in \`load’  
 from /opt/local/bin/postie:19

I don’t know where I live :(

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 3 Jan,
2008:</div>

<div class="comment" markdown="1">
Thanks for pointing that out Xavier, it’s now fixed in 1.0.1.

</div>
<div class="comment-author">
Sandy left a comment on 23 Feb, 2008:</div>

<div class="comment" markdown="1">
This is awesome. Just what i needed, was thinking of geocoding surburbs
and storing it all as post codes in the database but now im going to
simply use an autocomplete field with your gem. If i intend to use the
service on a commercial site, is their any issues with uptime? Should i
just grab the source and run it locally?

</div>
<div class="comment-author">
Sandy left a comment on 23 Feb, 2008:</div>

<div class="comment" markdown="1">
Noticed, something, this evening. It’s working really well at the
moment. I’m using a autocomplete helper and an on change handler to
update other parts of the form based on the selection. Just a quick tip
for others. Before parsing a form parameter with spaces. ie. if you
start typing the suburb “Red Hill” this will fail unless you substitute
the space for the plain text encoding “%20”. Other than that it works
flawlessly.

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 23 Feb,
2008:</div>

<div class="comment" markdown="1">
Sandy, glad to hear it’s useful for you - there’s no problems with using
it in a commercial app.

As for uptime, I can’t offer any guarantees, but I do have something
monitoring the site, so if it does go down, I’ll do my best to get it
back up and running asap.

As for escaping, I will fix that - it’s handled in the command line
tool, but not in the classes (which is really where the fix should be).
Expect a 1.0.2 release in the next 24 hours.

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 23 Feb,
2008:</div>

<div class="comment" markdown="1">
Okay, postie’s updated to handle spaces properly - will take a couple of
hours to propagate through rubygems though.

</div>
<div class="comment-author">
Sandy left a comment on 26 Feb, 2008:</div>

<div class="comment" markdown="1">
Yep, works fine without the gsub now. Response is fairly good with a
auto complete helper. Will see how it goes in production. Does the
service provide geocoded location data? At the moment i am using postie
as a helper when selecting a location and to prefill the database with
the correct data, then geocode on create if that postcode does not
already exist in the database (HABTM relationship). So over time it will
be optimized rather than pulling down the whole database from the
auspost site and performing extensive matching? Whether this is a better
approach i don’t know.

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 26 Feb,
2008:</div>

<div class="comment" markdown="1">
Sandy: There’s no geocoding information - only suburb, postcode, state
and comments provided by Australia Post. If you know of a source for
address or lat/long data, I’ll definitely consider mixing it in.

</div>
<div class="comment-author">
Sandy left a comment on 31 Jul, 2008:</div>

<div class="comment" markdown="1">
Hi pat,

I found a database with geodata attached.

http://www.phpandmore.org/2008/06/24/australian-post-code-geo-database/

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 1 Aug,
2008:</div>

<div class="comment" markdown="1">
Sandy: that’s awesome! Will have to find some time to get that into
postie somehow.

Thanks for the link.

</div>
<div class="comment-author">
Sandy left a comment on 1 Aug, 2008:</div>

<div class="comment" markdown="1">
Yeah, it took me a while to find. Alot of people on the net are charging
for similar packages. This one has been compiled from a number of free
sources, i’ve loaded everything into a table so i can query it. What is
the best approach to do the SQL finds on both suburb names and postcodes
simultaneously, like with postie, how you can enter either postcode or
enter a suburb and get back a result based on the data of two different
columns? Should you do a find by suburb and then a find by postcode and
then combine unique results?

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 2 Aug,
2008:</div>

<div class="comment" markdown="1">
Postie looks at the search term to see if it’s a postcode (ie: is it
four digits), and then uses it for just the one field (suburb or
postcode) depending on that.

I guess another way is something like
`SELECT * FROM locations WHERE suburb LIKE 'search%' OR postcode = 'search'`

</div>
<div class="comment-author">
Sandy left a comment on 4 Aug, 2008:</div>

<div class="comment" markdown="1">
Ok, thanks for that. Is the validation method the best method in terms
of performance? Or the SQL query?

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 4 Aug,
2008:</div>

<div class="comment" markdown="1">
Validation in terms of checking if it’s four digits? Not sure, but I’d
guess it’s probably faster that way. I’m doing it using a regular
expression: `/d/d/d/d` - which should keep things relatively fast,
instead of an OR statement with a half that isn’t needed. Pure guesswork
though.

</div>
<div class="comment-author">
<a href="http://www.phpandmore.org">Michael Baker</a> left a comment on
3 Sep, 2008:</div>

<div class="comment" markdown="1">
pat,  
Its a bit late but if you require any help with the DB let me know I
wrote the query’s ect.. for the content on my site PHP And More .org

</div>
</div>

