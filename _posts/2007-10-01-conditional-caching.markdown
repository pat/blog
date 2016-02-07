---
title: "Conditional Caching"
redirect_from: "/posts/conditional_caching/"
categories:
  - ruby
  - rails
  - caching
  - plugins
---
Whenever I’ve described caching in Rails to anyone who isn’t familiar
with it, I have made clear the limitations of each method:

-   Page caching is only useful when the output is exactly the same for
    every visitor, and you don’t need to confirm user authentication
-   Action caching allows you to run filters for every request - thus
    can be used to check if users are authenticated - but the rendered
    output has the same limitations as page caching
-   Fragment caching, while flexible, is definitely slower than the
    other two options.

Obviously, it’s best to use the fastest caching possible that fits your
pages. That’s rarely page caching for the sites I code. Even action
caching hasn’t been viable too often. Or so I thought.

I used to use fragment caching in most of my views - generally with
extra parameters to indicate user role, so it would store different
versions of the fragment for each role (ie: admin user, normal user, no
user). This worked reasonably well, but often I was wrapping an entire
view in a `<% cache do %>` block - almost action caching!

In the site I was coding at the time,
[ausdwcon.org](http://ausdwcon.org), I realised the best time to cache
would be when no user was logged in - as that would cover the majority
of requests. So, to simplify: what I wanted was caching only when a
certain condition was true.

Getting methods coded for conditional caching at a fragment level was a
piece of cake. At the action caching level? Well, that was trickier, but
with some help from the [RORO crew](http://www.rubyonrails.com.au) I got
it working, and into a plugin. You can find the code in the [RORO svn
repository](http://rails-oceania.googlecode.com/svn/patallan/conditional_caching/)
and the documentation on [this site](http://cc.freelancing-gods.com). To
install:

    script/plugin install
      http://rails-oceania.googlecode.com/svn/patallan/conditional_caching

One brief example so you know what to expect:

    # a controller
    caches_action :index, :if => :no_user?

    # application.rb
    def no_user?
      session[:user_id].empty?
    end

Obviously the `:if` parameter is the key - it can be a symbol pointer to
an instance method on the controller, or it can be a Proc which is
evaluated in the scope of the controller.

Now, the no-user condition is the only example I can think of where my
plugin is useful - if you think of others, please let me know. Keep
reading though, because I’ve got another helpful hint or two to share.

I mentioned above my usual method of using fragment caching - liberal
use of extra parameters. It’s actually possible to do this with action
caching too - which I only found out recently, so I’m assuming there are
other people out there who aren’t aware of it either.

It’s not quite as easy as the equivalent fragment caching code, as
you’re using both class and object level methods, but here’s an example:

    # a controller
    caches_action :index, :show, :cache_path => cache_params

    # application.rb
    def self.cache_params
      @cache_params ||= Proc.new { |controller|
        controller.params.merge(:role => controller.current_role)
      }
    end

This has actually made me cut back on usage of my plugin - because most
of my pages don’t have user-specific content.

Oh, and one more thing - to cut down on user-specific content in my
views, I’ve been mapping my users controller as both a normal resource
*and* a singleton resource. This means instead of a “Your Profile” link
being `/users/34`, it’s just `/user`. Makes the controller code a little
tricky, and the named routes get confused, but nothing a few clever
helper methods can’t fix.

------------------------------------------------------------------------

<div class="comments">
<div class="comment-author">
<a href="http://tiago.zusee.com">Tiago Bastos</a> left a comment on 7
Aug, 2008:</div>

<div class="comment" markdown="1">
Works on Rails 2.0.2?

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 7 Aug,
2008:</div>

<div class="comment" markdown="1">
Hi Tiago: I’m not sure if it’s friendly with 2.0.2 - it’s been a while
since I’ve really spent any time with this plugin. I’d expect it to work
though… I recently shifted a site that uses it over to Rails 2.1, and
there haven’t been any issues.

</div>
</div>

