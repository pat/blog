---
layout: riddle
title: Support
---


Getting Started
---------------

### Requirements

Firstly, you’ll want to [install Sphinx](installing_sphinx.html) and
[Riddle](installing_riddle.html). You can use either Sphinx 0.9.8 or
0.9.9, but don’t forget which version you’re using. In your Ruby code,
you’ll need to require the specific version of Riddle.

For example, using 0.9.8:

{% highlight ruby %}  
require ‘riddle’  
require ‘riddle/0.9.8’  
{% endhighlight %}

Or if you’re using using 0.9.9:

{% highlight ruby %}  
require ‘riddle’  
require ‘riddle/0.9.9’  
{% endhighlight %}

### Searching

You’ll need an active Client instance:

{% highlight ruby %}  
client = Riddle::Client.new ‘localhost’, 9312  
{% endhighlight %}

Obviously, change the address and port to suit, if necessary.

Searching is done via the `query` method:

{% highlight ruby %}  
client.query ‘search terms’, ‘index\_name’, ‘comment’  
{% endhighlight %}

The index name and comment are optional - the first will default to all
indexes (`'*'`), and the second to an empty string.

If you want to use different settings for your search request, you need
to set them up before you call the `query` method. This includes adding
filters or setting match modes.

{% highlight ruby %}  
client.match\_mode = :extended  
client.filters &lt;&lt; Riddle::Client::Filter.new(‘attribute’, \[1,
2\])  
{% endhighlight %}

### Excerpts

Documentation lacking.

### Updates

Documentation lacking.

### Status

Documentation lacking (although this feature is only for Sphinx 0.9.9,
so maybe that’s not a problem).

### Configuration

Documentation lacking, but Riddle’s configuration objects mirror
Sphinx’s, so it should be pretty easy to figure out. Some of its usage
can also be inferred by studying the Configuration model in
[ThinkingSphinx](https://github.com/pat/thinking-sphinx/) .

### Controller

Riddle’s controller object allows you to control the operation of sphinx
(starting, stopping, indexing…) in ruby. Documentation is lacking, but
some of its usage can be inferred by studying the Test and Configutation
models in [ThinkingSphinx](https://github.com/pat/thinking-sphinx/) .
