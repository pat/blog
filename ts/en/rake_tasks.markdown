---
layout: ts_en
title: Rake Tasks
---


Rake Tasks
----------

### Indexing

To index your data, you can run the following rake task:

{% highlight sh %}  
rake thinking\_sphinx:index  
{% endhighlight %}

There is also abbreviated versions, to save your fingers the few extra
keystrokes:

{% highlight sh %}  
rake ts:index  
rake ts:in  
{% endhighlight %}

The output of this task will look roughly like this:

{% highlight sh %}  
Generating Configuration to \\  
 /path/to/RAILS\_ROOT/config/development.sphinx.conf  
indexer —config /path/to/RAILS\_ROOT/config/development.sphinx.conf \\  
 —all  
Sphinx 0.9.8-release (r1371)  
Copyright © 2001-2008, Andrew Aksyonoff

using config file \\  
 ‘/path/to/RAILS\_ROOT/config/development.sphinx.conf’…  
indexing index ‘article\_core’…  
collected 10 docs, 0.0 MB  
collected 0 attr values  
sorted 0.0 Mvalues, 100.0% done  
sorted 0.0 Mhits, 100.0% done  
total 10 docs, 142 bytes  
total 0.101 sec, 1407.21 bytes/sec, 99.10 docs/sec  
indexing index ‘article\_delta’…  
collected 0 docs, 0.0 MB  
collected 0 attr values  
sorted 0.0 Mvalues, nan% done  
total 0 docs, 0 bytes  
total 0.010 sec, 0.00 bytes/sec, 0.00 docs/sec  
distributed index ‘article’ can not be directly indexed; skipping.  
{% endhighlight %}

This task, run normally, will also generate the configuration file for
Sphinx. If you decide to make custom changes, then you can disable this
generation running `reindex` instead.

{% highlight sh %}  
rake thinking\_sphinx:reindex  
{% endhighlight %}

If you’re using a version of Thinking Sphinx older than 1.3.10, then
`reindex` doesn’t exist, but you can do the same thing by setting the
INDEX\_ONLY environment variable to true:

{% highlight sh %}  
rake thinking\_sphinx:index INDEX\_ONLY=true  
{% endhighlight %}

### Generating the Configuration File

If you need to just generate the configuration file, without indexing
(something that can be useful when deploying), here’s the task (and
shortcuts) to do it:

{% highlight sh %}  
rake thinking\_sphinx:configure  
rake ts:conf  
rake ts:config  
{% endhighlight %}

Expected output:

{% highlight sh %}  
Generating Configuration to \\  
 /path/to/RAILS\_ROOT/config/development.sphinx.conf  
{% endhighlight %}

### Starting and Stopping Sphinx

If you actually want to search against the indexed data, then you’ll
need Sphinx’s searchd daemon to be running. This can be controlled using
the following tasks:

{% highlight sh %}  
rake thinking\_sphinx:start  
rake ts:start  
rake thinking\_sphinx:stop  
rake ts:stop  
{% endhighlight %}

Expected outputs:

{% highlight sh %}  
searchd —pidfile —config \\  
 /path/to/RAILS\_ROOT/config/development.sphinx.conf  
Sphinx 0.9.8-release (r1371)  
Copyright © 2001-2008, Andrew Aksyonoff

using config file \\  
 ‘/path/to/RAILS\_ROOT/config/development.sphinx.conf’…  
Started successfully (pid 12928).  
{% endhighlight %}

{% highlight sh %}  
Sphinx 0.9.8-release (r1371)  
Copyright © 2001-2008, Andrew Aksyonoff

using config file \\  
 ‘/path/to/RAILS\_ROOT/config/development.sphinx.conf’…  
stop: succesfully sent SIGTERM to pid 12928  
Stopped search daemon (pid 12928).  
{% endhighlight %}

### Rebuilding Sphinx Indexes

When you make changes to your Sphinx index structure, you will need to
stop and start Sphinx for these changes to take effect, as well as
re-index the data. This is all wrapped up into a single task:

{% highlight sh %}  
rake thinking\_sphinx:rebuild  
rake ts:rebuild  
{% endhighlight %}

### Handling Delta Indexes

If you’re using either the Delayed Job or Datetime/Timestamp delta
approaches, you’ll need to run a task to manage the indexing. For the
Delayed Job setup, the rake task runs constantly, processing any delta
jobs (as well as any other normal jobs if you’re using the delayed\_job
plugin elsewhere in your application).

{% highlight sh %}  
rake thinking\_sphinx:delayed\_delta  
rake ts:dd  
{% endhighlight %}

For those using Datetime Deltas, you’ll need to run the following task
at a regular interval - whatever your threshold is set to.

{% highlight sh %}  
rake thinking\_sphinx:index:delta  
rake ts:in:delta  
{% endhighlight %}

### Checking your version of Thinking Sphinx

There is also a rake task for outputting the version of Thinking Sphinx
you’re using.

{% highlight sh %}  
rake thinking\_sphinx:version  
rake ts:version  
{% endhighlight %}

{% highlight sh %}  
Thinking Sphinx v1.1.16  
{% endhighlight %}
