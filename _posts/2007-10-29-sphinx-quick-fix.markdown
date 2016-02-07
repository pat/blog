---
title: "Sphinx Quick Fix"
redirect_from: "/posts/sphinx_quick_fix/"
categories:
  - search
  - mac
  - leopard
  - sphinx
---
Here’s one small filesystem tweak that’s been handy as I’ve been slowly
rebuilding my development environment on Leopard over the last couple of
days. It’s to get [Sphinx](http://www.sphinxsearch.com) working - there
was no problems with compilation or installation, but when I ran searchd
or indexer, it complained about not finding the mysql libraries:

    dyld: Library not loaded: /usr/local/mysql/lib/mysql/libmysqlclient.15.dylib
      Referenced from: /usr/local/bin/indexer
      Reason: image not found

Now, the expected file path is incorrect - it shouldn’t have the second
‘mysql’. My attempts to change that with various configuration flags
didn’t work, so I cheated, and added the folder as a symbolic link:

    sudo ln -s /usr/local/mysql/lib /usr/local/mysql/lib/mysql

Suggestions of a cleaner solution always welcome.

------------------------------------------------------------------------

<div class="comments">
<div class="comment-author">
<a href="http://joncrawford.com">Jon Crawford</a> left a comment on 4
Jul, 2008:</div>

<div class="comment" markdown="1">
Hey, I just found this article while having similar issues. I found this
article at the same time.  
http://mrpmorris.blogspot.com/2007/06/installing-rails-on-mac.html

Towards the bottom it speaks about these issues and offers a different
solution and an explanation for the problem. I went with your solution
for fear of screwing up my currently-functioning Rails stack.

I don’t understand all the mechanics of everything, but if you think the
other article is a better solution, please let me know.

Thanks!

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 4 Jul,
2008:</div>

<div class="comment" markdown="1">
Hi Jon

Good to know this post was helpful to someone. Looking at the other
solution, I’m not sure which is better - they are using an Apple CLI
tool, so perhaps that’s the recommended solution… but like you, I don’t
have my head around the mechanics of it all, so I’m not sure.

</div>
<div class="comment-author">
Reset left a comment on 18 May, 2009:</div>

<div class="comment" markdown="1">
Late response, but this might be helpful for somebody.

When you ./configure sphinx you should specify your lib and includes
directory like this..

./configure —with-mysql-includes=/usr/local/mysql/include/mysql/
—with-mysql-libs=/usr/local/mysql/lib/mysql/

That should solve your problem.

</div>
</div>

