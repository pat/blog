---
layout: ts_en
title: Installing Sphinx
---


Installing Sphinx
-----------------

### MacOS X

Sphinx *is* available via MacPorts - but this comes with one important
caveat: You must have MySQL and/or PostgreSQL installed via MacPorts as
well. If you don’t, then compiling by source is the best approach.
[Download](http://www.sphinxsearch.com/downloads.html) and try the
following set of commands. *If you need PostgreSQL* support though,
scroll down and look at the UNIX section.

{% highlight sh %}  
./configure  
make  
sudo make install  
{% endhighlight %}

There are two common issues that people run into. The first is that
iconv and/or the expat XML parser may need to be updated. Clinton Nixon
has [written some clear
instructions](http://www.viget.com/extend/installing-sphinx-on-os-x-leopard)
on how to handle that.

The other issue only appears when you actually index your data or start
the daemon:

{% highlight sh %}  
dyld: Library not loaded: \\  
 /usr/local/mysql/lib/mysql/libmysqlclient.15.dylib  
 Referenced from: /usr/local/bin/indexer  
 Reason: image not found  
{% endhighlight %}

A quick fix for this is to add a symlink from where the MySQL libraries
are to where Sphinx expects them to be:

{% highlight sh %}  
sudo ln -s /usr/local/mysql/lib /usr/local/mysql/lib/mysql  
{% endhighlight %}

You may need to recompile and reinstall Sphinx once this is done.

### UNIX

If you’re running Gentoo, then Sphinx is available via `portage`. Debian
and Ubuntu have the `sphinxsearch` package available to them in apt. I
don’t know what the status is for other distributions and package
management tools, so you may need to compile it yourself.

Compiling by source should be quite painless though. [Download the
code](http://www.sphinxsearch.com/downloads.html) from the Sphinx
website - version 0.9.8.1 is the most recent stable release at the
moment. The standard set of commands should install it with MySQL
support:

{% highlight sh %}  
./configure  
make  
sudo make install  
{% endhighlight %}

If you need PostgreSQL support, you’ll need to tell the Sphinx
configuration step that. It could be as simple as a flag:

{% highlight sh %}  
./configure —with-pgsql  
{% endhighlight %}

But in some cases the path to the libraries will need to be explicitly
set:

{% highlight sh %}  
./configure —with-pgsql=/usr/local/include/postgresql  
{% endhighlight %}

The libraries path can be determined by running the following command:

{% highlight sh %}  
pg\_config —pkgincludedir  
{% endhighlight %}

### Windows

If you’re installing Sphinx on Windows, then all you should have to do
is grab [the relevant
installer](http://www.sphinxsearch.com/downloads.html) from the Sphinx
website (one has PostgreSQL and MySQL support, one is just for MySQL).
Install, and you’re good to go.
