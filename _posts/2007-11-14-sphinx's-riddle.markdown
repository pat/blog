---
title: "Sphinx's Riddle"
redirect_from: "/posts/sphinx's_riddle/"
categories:
  - plugins
  - search
  - sphinx
  - ruby
  - rails
---
**Edit**: I’ve changed the Subversion reference to Github, and it’s
worth noting that Riddle works with Sphinx 0.9.8, 0.9.9 and 1.10-beta at
the time of writing (January 2011). Original post continues below:

Built out of the work I’ve done for [Thinking
Sphinx](http://ts.freelancing-gods.com) (which has just got basic
support for delta indexes, attributes and sorting - although the
documentation doesn’t reflect that), I’ve extracted a new Ruby client
that communicates with Sphinx, which I’ve named
[Riddle](http://riddle.freelancing-gods.com).

I’m not going to delve into the code here - because I’m not expecting it
to be *that* useful to many people (and I just wrote examples in the
documentation - go read that instead!) - but I’m very happy with how
it’s ended up, and it’s got some level of specs to give it a thorough
test. It’s also compatible with the most recent release of Sphinx (0.9.8
r871). Should you wish to poke around with it, just clone it from
Github:

    git clone \
      git://github.com/freelancing-god/riddle.git

It’s also being used in Evan Weaver’s
[UltraSphinx](http://blog.evanweaver.com/files/doc/fauna/ultrasphinx/files/README.html)
plugin, which I’m pretty pleased about.

------------------------------------------------------------------------

<div class="comments">
<div class="comment-author">
Bork left a comment on 14 Nov, 2007:</div>

<div class="comment" markdown="1">
Bork Bork Bork.

</div>
<div class="comment-author">
Joost left a comment on 23 Nov, 2007:</div>

<div class="comment" markdown="1">
Works excellent this one! Thanks!

</div>
<div class="comment-author">
golak left a comment on 23 Apr, 2008:</div>

<div class="comment" markdown="1">
hi,  
Thanks for the wonderful ruby wrapper for sphinx api. I am using it on a
project of mine. I won’t be using thinking sphinx because of the
architecture that i have adopted. could you please clarify one simple
doubt which i am somehow getting wrong. how do i use the sorting mode
SPH\_SORT\_EXPR  
i tried the following syntax but its generating error  
riddle.sort\_mode = :expr  
riddle.sort\_by = ‘@weight \* page\_rank DESC’

thanks for your help in advance

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 23 Apr,
2008:</div>

<div class="comment" markdown="1">
Hi golak

I’ve not had the opportunity to use the expression sorting mode - but
your syntax looks right to me. Perhaps remove the DESC? None of the
examples in [the
documentation](http://sphinxsearch.com/doc.html#sorting-modes) have
that. If that doesn’t help, shoot me an email with the error stack
trace, I’m happy to look into it.

</div>
<div class="comment-author">
<a href="http://www.sourcingup.com">Rodrigo Aronas</a> left a comment on
1 Apr, 2009:</div>

<div class="comment" markdown="1">
Hello,  
I’m newby in ultrasphinx, and i’m egtting a headache trying to use the
mode :expr with RoR.  
Here’s what I’m using:  
\#`search = Ultrasphinx::Search.new(:class_names => `types, :query =&gt;
“**\#{@query}**”, :per\_page =&gt; `per_page, :page => `page, :weights
=&gt; `weights, :filters => `query\_filters, :sort\_mode =&gt;
‘expression’, :sort\_by=&gt;\[‘@weight *trust\*100 - deprecated \*
10000* rating\_count \* 1000 -percent\_variation\*100
-monetary\_price’\])

And i’m getting an error of SortMode invalid.

does anybody knows the way to do this?  
Thanks in advance!

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 1 Apr,
2009:</div>

<div class="comment" markdown="1">
Hi Rodrigo

I’m not entirely sure how UltraSphinx works, but if it is just passing
through the sort\_mode argument to Riddle, then you want to use `:expr`
instead of `'expression'`.

</div>
<div class="comment-author">
<a href="http://www.sourcingup.com">Rodrigo</a> left a comment on 15
Apr, 2009:</div>

<div class="comment" markdown="1">
Hello again, I went back on this sphinx stuff that didn’t work for me,
and i’m still having this problem, it continues giving me the “Sortmode
”expr" / “expression” or whatever i put INVALID.  
I’m stucked with this, any comments would be appreciated.  
Thanks.

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 16 Apr,
2009:</div>

<div class="comment" markdown="1">
Hi Rodrigo

Are you setting sort\_mode as a symbol or a String? Because it needs to
be a symbol. If you want to continue this discussion on [the Thinking
Sphinx google group](http://groups.google.com/group/thinking-sphinx),
then we can discuss this further, and with code examples.

</div>
</div>

