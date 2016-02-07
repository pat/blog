---
title: "Mixing Merb and MYOB"
redirect_from: "/posts/mixing_merb_and_myob/"
categories:
  - merb
  - myob
  - odbc
  - ruby
  - rails
---
For one of the contracts I’m working on at the moment, I’ve been using
[Merb](http://merbivore.com/) to construct a web service that interacts
with MYOB, and can be consumed with ActiveResource.

The connection to MYOB is ugly, using [Christian Werner’s ODBC
Bindings](http://ch-werner.de/rubyodbc/) and the [Rails/ActiveRecord
ODBC Adapter](http://odbc-rails.rubyforge.org/), the latter of which had
to be hacked slightly. However, the Merb side of things was quite clean.
I’m really looking forward to seeing how Merb progresses, especially
with their plans for [merb\_core and
merb\_more](http://yehudakatz.com/2008/01/14/merbnext/).

One of the rare snippets of code from the Merb app that I think is more
verbose than the Rails equivalent is how to go about obtaining the query
parameters (as opposed to routing parameters) of a request.

The Rails way:

    request.query_parameters

The Merb way:

    params.except *request.route_params.keys.collect { |key| key.to_s }

Also, in case you’re as stupid as I am and want to generate Merb
controllers on the fly, you can’t use Class.new. The only way is by
building the class in a string and eval’ing it:

    Object.send(:eval, <<-CODE
    class ::Object::#{controller_name} < Application
      # actions and such go here
    end
    CODE
    )

It’s not particularly elegant, but at least it works.

------------------------------------------------------------------------

<div class="comments">
<div class="comment-author">
Zachery left a comment on 12 Feb, 2008:</div>

<div class="comment" markdown="1">
thnx for the read. im actually working on replacing myob for a small
company to Merb and a local AIR application. If you have any tips for
handling MYOB / converting the data possibly id be extremely thankful. I
haven’t looked into getting the ‘license’ required for MYOB to support
odbc yet, will have to do that this week. thnx again for the read.

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 12 Feb,
2008:</div>

<div class="comment" markdown="1">
Hi Zachery

I’ll try to get a post up in the next day or two with some more details
about how to talk to MYOB using Ruby. In the meantime, feel free to
shoot me any questions you have via email (pat at this domain).

</div>
</div>

