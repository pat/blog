---
title: "Versioning your APIs"
redirect_from: "/posts/versioning_your_ap_is/"
categories:
  - ruby
  - rails
  - api
  - flying sphinx
---
As I developed [Flying Sphinx](http://flying-sphinx.com), I found myself
both writing and consuming several APIs: from Heroku to Flying Sphinx,
Flying Sphinx to Heroku, the `flying-sphinx` gem in apps to Flying
Sphinx, Flying Sphinx to Sphinx servers, and Sphinx servers to Flying
Sphinx.

None of that was particularly painful - but when [Josh
Kalderimis](http://blog.cookiestack.com/) was improving the
`flying-sphinx` gem, he noted that the API it interacts with wasn’t that
great. Namely, it was inconsistent with what it returned (sometimes text
status messages, sometimes JSON), it was sending authentication
credentials as GET/POST parameters instead of in a header, and it wasn’t
versioned.

I was thinking that given I control pretty much every aspect of the
service, it didn’t matter if the APIs had versions or not. However, as
Josh and I worked through improvements, it became clear that the apps
using older versions of the `flying-sphinx` gem were going to have one
expectation, and newer versions another. Versioning suddenly became a
much more attractive idea.

The next point of discussion was how clients should specify which
version they are after. Most APIs put this in the path - here’s
Twitter’s as an example, specifying version 1:

    https://api.twitter.com/1/statuses/user_timeline.json

However, I’d recently been working with Scalarium’s API, and theirs put
the version information in a header (again, version 1):

    Accept: application/vnd.scalarium-v1+json

Some research turned up [a discussion on Hacker
News](http://news.ycombinator.org/item?id=1523664) about best practices
for APIs - and it’s argued there that using headers keeps the paths
focused on just the resource, which is a more RESTful approach. It also
makes for cleaner URLs, which I like as well.

How to implement this in a Rails application though? My routing ended up
looking something like this:

    namespace :api do
      constrants ApiVersion.new(1) do
        scope :module => :v1 do
          resource :app do
            resources :indices
          end
        end
      end

      constraints ApiVersion.new(2) do
        scope :module => :v2
          resource :app do
            resources :indices
          end
        end
      end
    end

The ApiVersion class (which I have saved to `app/lib/api_version.rb`) is
where we check the version header and route accordingly:

    class ApiVersion
      def initialize(version)
        @version = version
      end

      def matches?(request)
        versioned_accept_header?(request) || version_one?(request)
      end

      private

      def versioned_accept_header?(request)
        accept = request.headers['Accept']
        accept && accept[/application\/vnd\.flying-sphinx-v#{@version}\+json/]
      end

      def unversioned_accept_header?(request)
        accept = request.headers['Accept']
        accept.blank? || accept[/application\/vnd\.flying-sphinx/].nil?
      end

      def version_one?(request)
        @version == 1 && unversioned_accept_header?(request)
      end
    end

You’ll see that I default to version 1 if no header is supplied. This is
for the older versions of the flying-sphinx gem - but if I was starting
afresh, I may default to the latest version instead.

All of this gives us URLs that look like something like this:

    http://flying-sphinx.com/api/app
    http://flying-sphinx.com/api/app/indices

My SSL certificate is locked to flying-sphinx.com - if it was
wildcarded, then I’d be using a subdomain ‘api’ instead, and clean those
URLs up even further.

The controllers are namespaced according to both the path and the
version - so we end up with names like `Api::V2::AppsController`. It
does mean you get a new set of controllers for each version, but I’m
okay with that (though would welcome suggestions for other approaches).

Authentication is managed by namespaced application controllers - here’s
an example for version 2, where I’m using headers:

    class Api::V2::ApplicationController < ApplicationController
      skip_before_filter :verify_authenticity_token
      before_filter :check_api_params

      expose(:app) { App.find_by_identifier identifier }

      private

      def check_api_params
        # ensure the response returns with the same header value
        headers['X-Flying-Sphinx-Token'] = request.headers['X-Flying-Sphinx-Token']
        render_json_with_code 403 unless app && app.api_key == api_key
      end

      def api_token
        request.headers['X-Flying-Sphinx-Token']
      end

      def identifier
        api_token && api_token.split(':').first
      end

      def api_key
        api_token && api_token.split(':').last
      end
    end

Authentication, in case it’s not clear, is done by a header named
X-Flying-Sphinx-Token with a value of the account’s identifier and
api\_key concatenated together, separated by a colon.

(If you’re not familiar with the `expose` method, that’s from the
excellent `decent_exposure` gem.)

So where does that leave us? Well, we have an elegantly namespaced API,
and both versions and authentication is managed in headers instead of
paths and parameters. I also made sure version 2 responses all return
JSON. Josh is happy and all versions of the `flying-sphinx` gem are
happy.

The one caveat with all of this? While it works for me, and it suits
Flying Sphinx, it’s not the One True Way for API development. We had a
great discussion at the most recent [Rails Camp](http://railscamps.com)
up at Lake Ainsworth about different approaches - at the end of the day,
it really comes down to the complexity of your API and who it will be
used by.

------------------------------------------------------------------------

<div class="comments">
<div class="comment-author">
<a href="http://harrylove.org">Harry</a> left a comment on 26 Sep,
2011:</div>

<div class="comment" markdown="1">
I’m totally in agreement with those who advocate keeping API versions
out of the URI. “Cool URIs don’t change.” I remember Paul Sadauskas
talking about this method of using the Accept header at the Boulder Ruby
Group a few years ago. For REST APIs, it’s the only way to go.

As for your implementation, I think namespacing is a great way to handle
it. Another method you might consider, although it gets more complex, is
to deploy separate apps and then route in your web server based on the
Accept header. If your API lasts more than a few years, eventually
you’ll want to stop supporting a version. The easiest way to turn it off
is to remove it. Then you’re left with serving only the versions you
support and it keeps your app clean. Of course there’s code duplication,
but you’d be doing that anyway. It also means if one version of the API
is super popular, you can give it more hardware resources. E.g., when
version 3 is released you can give it an entire cluster and you can move
version 1 onto a single server for six months before you kill it.

Like I said, more complex, but it’s another strategy.

</div>
<div class="comment-author">
Dave T left a comment on 26 Sep, 2011:</div>

<div class="comment" markdown="1">
Personally, I kind of like the version in an API url, but if you don’t
want it, then this is a good solution. One advantage of having the
version in the Url or a header is that http middleware (load balancers,
proxies, etc …) can utilize this. If you only put it in the payload, it
is hidden from those devices.

</div>
<div class="comment-author">
Mark left a comment on 27 Sep, 2011:</div>

<div class="comment" markdown="1">
Sure, the version should stay out of the URI, because otherwise you have
the same resource available under different URIs.

But we want to force our consumers to specify a version (there is no
default and nothing like ‘latest’), which makes the API more stable,
because a new version of the API won’t affect any existing consumers.
But this would mean letting the request fail if the consumer doesn’t
specified the right header information. That also feels wrong in a way
and makes the other approach (putting the version in the URI) more
appealing.

</div>
<div class="comment-author">
<a href="http://perfectskies.com">David Backeus</a> left a comment on 27
Sep, 2011:</div>

<div class="comment" markdown="1">
How come you chose not to use basic http authentication?

Looks like you had a perfect fit ([username]("password")).

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 27 Sep,
2011:</div>

<div class="comment" markdown="1">
David: to be honest, I didn’t think of it. I’d been using Scalarium’s
API recently, and I liked how that worked, so it definitely influenced
my decisions. But HTTP Authentication combined with SSL is certainly a
good approach.

Mark: you could just return JSON/XML stating that the version header is
required if it’s not provided. But yeah, I can see that’s not ideal
either.

Dave: there’s definitely advantages of having the version in the path,
for sure. I don’t think I’ll have any need for middleware to have to do
anything complex though, so it’s not an issue for me in the case of
Flying Sphinx.

Harry: thanks for the detailed feedback! Having completely separate apps
for different versions is something we discussed at Rails Camp, and it’s
certainly worth considering if it’s a large and/or complex API you’re
building.

</div>
<div class="comment-author">
Lee Hambley left a comment on 27 Sep, 2011:</div>

<div class="comment" markdown="1">
I particularly like that you took the time to research, and share how to
do this with Rails routing constraints, quite a beautiful solution, and
not something that should be under discussion anymore, according to all
the specs, this the “right” way to build an API as far as anyone knows
in 2011.

</div>
<div class="comment-author">
Frederic left a comment on 27 Sep, 2011:</div>

<div class="comment" markdown="1">
Do not embed the (API) version in your media types. Doing so, you create
new types that have nothing (semanticaly speaking) to do with the
“previous” version.

The Accept: and Content-Type: headers can be given parameters after the
media type, so the client simply “Accept: your/media-type; version=2.0;
q=0.9, your/media-type; version=1.0; q=0.1” (compatible with 2 versions
of the API, but prefer the new one), and the server reply with
“Content-Type: your/media-type; version=1.0” (no luck: it’s an old
server ;-))

Or instead of a “version” attribute, use a “level” one, like described
in [RFC 2854 (The ‘text/html’ Media
Type)](http://tools.ietf.org/html/rfc2854)

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 27 Sep,
2011:</div>

<div class="comment" markdown="1">
Thanks for that feedback Frederic, will definitely keep it in mind for
the next API I write.

</div>
<div class="comment-author">
<a href="http://urtak.com/">Kunal</a> left a comment on 27 Sep,
2011:</div>

<div class="comment" markdown="1">
For some more discussion on good REST practices like this, check out the
credits on:

http://developer.urtak.com

We’re releasing our API this coming week and I’ve done the same with the
vendor mime-type but I have not yet implemented the logic (beyond
rejecting of malformed Accepts headers) server side yet. Your pattern,
Pat, is very nice and I think I’ll go with it!

</div>
<div class="comment-author">
<a href="http://bibwild.wordpress.com">Jonathan Rochkind</a> left a
comment on 27 Sep, 2011:</div>

<div class="comment" markdown="1">
“It does mean you get a new set of controllers for each version, but I’m
okay with that (though would welcome suggestions for other approaches).”

You could try to do something with inheritance, so v2 controllers
inherit from v1, and only need to implement methods that have changed.

I’m not sure if it would be worth or not, it probably depends. Brings
it’s own set of confusing issues. And you’d still need a seperate set of
controllers, they could just be mostly empty.

Can’t think of any other great approach.

</div>
<div class="comment-author">
<a href="http://bibwild.wordpress.com">Jonathan Rochkind</a> left a
comment on 27 Sep, 2011:</div>

<div class="comment" markdown="1">
Woah, actually I just had an idea and played around with it to see if it
would work, if you make the V2 module ‘inherit’ (via ‘include’) the V1
module, you don’t even need empty classes, you get all the classes from
V1 in V2, unless you over-ride em. I think. This would take more
experimentation/research to make sure it does what you want.

Not sure it’s worth the added complexity, it depends on how much logic
you are duplicating, and how much it matters. (Theoretically V1 is never
going to be touched after V2 is out, so who cares if there’s
copy-and-pasted code between them, V1 is frozen. Unless bug fixes come
into it.)

Check it out:

https://gist.github.com/1246840

</div>
<div class="comment-author">
<a href="http://dagi3d.net">dagi3d</a> left a comment on 28 Sep,
2011:</div>

<div class="comment" markdown="1">
Hi Pat,  
thanks for sharing this article. I wrote another post based on it with
some extra thoughts about the authentication in case anyone is
interested: http://dagi3d.net/posts/5-api-authentication

</div>
<div class="comment-author">
<a href="http://www.zwapp.com">Jeroen van Dijk</a> left a comment on 1
Oct, 2011:</div>

<div class="comment" markdown="1">
Hi Pat,

Thanks for sharing. I think Harry’s idea of hosting different versions
of your API seperately could work really nicely. Especially, when you
tag those versions in Git. V1 will stay in the V1 branch and in the new
master branch (V2) V1 would not exist anymore, so no code duplication or
complex inheritance needed. Only when you need to fix something on V1
you would checkout V1, fix something and redeploy V1.

The setup might be a bit more difficult, but I’m guessing it is worth
it.

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 1 Oct,
2011:</div>

<div class="comment" markdown="1">
Thanks for the comments Jonathan, Borja, Jeroen - it’s good to know this
has sparked some thoughts.

Modules as a replacement for inheritance could work - whether it’s clean
enough to warrant would depend on the situation, I guess. Ditto for
separate branches - that comes down to how complex your app is, and
whether you’ve got multiple repos and/or a not-so-simple hosting setup
for the one project. Definitely both worth considering.

And Borja - well done on putting specs in your blog post as well as the
implementation code - that really should be done more!

</div>
<div class="comment-author">
Nadav left a comment on 2 Oct, 2011:</div>

<div class="comment" markdown="1">
Great post![]()  
Pat, I guess if you include modules - each representing a version, in
the controller, then you have to use some naming convention to make sure
that methods defined in the modules don’t override each other.

</div>
<div class="comment-author">
<a href="http://mt7.de">Thorsten</a> left a comment on 11 Oct,
2011:</div>

<div class="comment" markdown="1">
Thanks for the nice post! But I think your implementation won’t work as
expected.

Using a routing constraint like you do leads to a
ActionController::RoutingError if the constraint condition
(ApiVersion(i)) is not met, stopping execution of the routing at all.

I tried this out and after reading the Rails source code (3.0.10 and
3.1.1) this is expected behavior, because constraints are meant to be
used as a one-shot guard for a route.

Does your solution work for you? Did you ever try out to reach the
Api::V2::IndicesController?

Thanks for you answer!

</div>
<div class="comment-author">
<a href="http://mt7.de">Thorsten</a> left a comment on 12 Oct,
2011:</div>

<div class="comment" markdown="1">
Okay, my last comment missed the point. Your solution does work! My
problem came from a gem we use together with your constraints way:
[routing-filter](https://github.com/svenfuchs/routing-filter) . Inside
that, the handling of blocks is interrupted in the way Rails (or
rack-mount) expects it.

Sorry for blaming your way for it ;-)

</div>
<div class="comment-author">
Glenn left a comment on 3 Apr, 2012:</div>

<div class="comment" markdown="1">
Thanks for this article…helped me loads. Just finished the first go at
versioning our api and used your approach.

</div>
<div class="comment-author">
Miguel left a comment on 20 Nov, 2012:</div>

<div class="comment" markdown="1">
Thanks for the article!

I do have one question, I implemented something like this, and I do not
know how to test it. Do you have any information regarding testing
routing constraints? or do you have the rspec of this particular
constraint?

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 20 Nov,
2012:</div>

<div class="comment" markdown="1">
Hi Miguel

The HTTP methods in RSpec (get, post, put, delete) all accept a third
parameter for headers, so you can specify authentication and version
headers through that easily enough. Here’s a [quick
example](https://gist.github.com/4121959).

Using that approach, you can have tests for each version of each API
call, checking for the appropriate behaviour.

</div>
<div class="comment-author">
Vadim Golub left a comment on 22 Jul, 2013:</div>

<div class="comment" markdown="1">
Hi Pat,

thanks for the article. I agree about keeping version out of URI as
well.  
However your example will return 404 if unsupported version is
specified, but it makes more sense to return 406 Not Acceptable.  
I tried to implement it like this
https://gist.github.com/memph1s/6053379, but I’m not sure if it’s a good
idea. Maybe you have any ideas how to do this better way?

Thanks!

</div>
</div>

