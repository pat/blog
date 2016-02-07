---
title: "Rewriting Thinking Sphinx: Middleware, Glazes and Panes"
redirect_from: "/posts/rewriting_thinking_sphinx_middleware_glazes_and_panes/"
categories:
  - sphinx
  - thinking sphinx
  - ruby
  - rails
  - middleware
---
Time to discuss more changes to Thinking Sphinx with the v3 releases -
this time, the much improved extensibility.

There have been a huge number of contributors to Thinking Sphinx over
the years, and each of their commits are greatly appreciated. Sometimes,
though, the pull requests that come in cover extreme edge cases, or
features that are perhaps only useful to the committer. But running your
own hacked version of Thinking Sphinx is not cool, and then you’ve got
to keep an especially close eye on new commits, and merge them in
manually, and… blergh.

So instead, we now have middleware, glazes and panes.

Middleware
----------

The middleware pattern is pretty well-established in the Ruby community,
thanks to Rack - but it’s started to crop up in other libraries too
(such as Mike Perham’s excellent [Sidekiq](http://sidekiq.org)).

In Thinking Sphinx, middleware classes are used to process search
requests. The default set of middleware are as follows:

-   `ThinkingSphinx::Middlewares::StaleIdFilter` adding an attribute
    filter to hide search results that are known to not match any
    ActiveRecord objects.
-   `ThinkingSphinx::Middlewares::SphinxQL` generates the SphinxQL query
    to send to Sphinx.
-   `ThinkingSphinx::Middlewares::Geographer` modifies the SphinxQL
    query with geographic co-ordinates if they’re provided via the
    `:geo` option.
-   `ThinkingSphinx::Middlewares::Inquirer` sends the constructed
    SphinxQL query through to Sphinx itself.
-   `ThinkingSphinx::Middlewares::UTF8` ensures all string values
    returned by Sphinx are encoded as UTF-8.
-   `ThinkingSphinx::Middlewares::ActiveRecordTranslator` translates
    Sphinx results into their corresponding ActiveRecord objects.
-   `ThinkingSphinx::Middlewares::StaleIdChecker` notes any Sphinx
    results that don’t have corresponding ActiveRecord objects, and
    retries the search if they exist.
-   `ThinkingSphinx::Middlewares::Glazier` wraps each search result in a
    glaze if there’s any panes set for the search (read below for an
    explanation on this).

Each middleware does its thing, and then passes control through to the
next one in the chain. If you want to create your own middleware, your
class must respond to two instance methods: `initialize(app)` and
`call(contexts)`.

If you subclass from `ThinkingSphinx::Middlewares::Middleware` you’ll
get the first for free. `contexts` is an array of search context
objects, which provide access to each search object along with the raw
search results and other pieces of information to note between
middleware objects. Middleware are written to handle multiple search
requests, hence why contexts is an array.

If you’re looking for inspiration on how to write your own middleware,
have a look through [the
source](https://github.com/pat/thinking-sphinx/tree/master/lib/thinking_sphinx/middlewares)
- and here’s [an extra example](https://gist.github.com/pat/4471233) I
put together when considering approaches to multi-tenancy.

Glazes and Panes
----------------

Sometimes it’s useful to have pieces of metadata associated with each
search result - and it could be argued the cleanest way to do this is to
attach methods directly to each ActiveRecord instance that’s returned by
the search.

But inserting methods on objects on the fly is, let’s face it, pretty
damn ugly. But that’s precisely what older versions of Thinking Sphinx
do. I’ve never liked it, but I’d never spent the time to restructure
things to work around that… until now.

There are now a few panes available to provide these helper methods:

-   `ThinkingSphinx::Panes::AttributesPane` provides a method called
    `sphinx_attributes` which is a hash of the raw Sphinx
    attribute values. This is useful when your Sphinx attributes hold
    complex values that you don’t want to re-calcuate.
-   `ThinkingSphinx::Panes::DistancePane` provides the identical
    `distance` and `geodist` methods returning the calculated distance
    between lat/lng geographical points (and is added automatically if
    the `:geo` option is present).
-   `ThinkingSphinx::Panes::ExcerptsPane` provides access to an
    `excerpts` method which you can then chain any call to a method on
    the search result - and get an excerpted value returned.
-   `ThinkingSphinx::Panes::WeightPane` provides the weight method,
    returning Sphinx’s calculated relevance score.

None of these panes are loaded by default - and so the search results
you’ll get are the actual ActiveRecord objects. You can add specific
panes like so:

    # For every search
    ThinkingSphinx::Configuration::Defaults::PANES << ThinkingSphinx::Panes::WeightPane

    # Or for specific searches:
    search = ThinkingSphinx.search('pancakes')
    search.context[:panes] << ThinkingSphinx::Panes::WeightPane

When you do add at least pane into the mix, though, the search result
gets wrapped in a glaze object. These glaze objects direct any methods
called upon themselves with the following logic:

-   If the search result responds to the given method, send it to that
    search result.
-   Else if any pane responds to the given method, send it to the pane.
-   Otherwise, send it to the search result anyway.

This means that your ActiveRecord instances take priority – so pane
methods don’t overwrite your own code. It also allows for
method\_missing metaprogramming in your models (and ActiveRecord itself)
– but otherwise, you can get access to the useful metadata Sphinx can
provide, without monkeypatching objects on the fly.

If you’re writing your own panes, the only requirement is that the
initializer must accept three arguments: the search context, the
underlying search result object, and a hash of the raw values from
Sphinx. Again, [the source
code](https://github.com/pat/thinking-sphinx/tree/master/lib/thinking_sphinx/panes)
for the panes is not overly complex - so have a read through that for
inspiration.

I’m always keen to hear about any middleware or panes other people write
- so please, if you do make use of either of these approaches, let me
know!
