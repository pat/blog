---
title: "Rack APIs with Sliver"
categories:
  - ruby
  - rails
  - rack
  - api
  - sliver
---

Over the last handful years, I've written a lot of JSON-focused APIs. Instead of using normal Rails controllers, I've often reached for [Grape](https://github.com/intridea/grape), as it's lighter and simpler than Rails, and is built with APIs in mind.

As our API would grow, though, the Ruby file containing all the logic would grow as well. Grape allows for separating common methods out into helper modules, which helps somewhat, but I'm generally not a fan of modules for shared code anyway - I'll opt for objects built for a specific purpose where possible. (For the record, this is also why I don't like Rails' approach to view helpers: injecting hundreds of methods into a single context makes for one very crowded view context.)

Of course, there are indeed ways we could structure our API across multiple files with Grape (or Rails, or Sinatra) so it becomes easier to maintain and extend - but when this headache arose, I took the opportunity to ponder what I *really* wanted to use:

* Something built on Rack, so it Just Works with various Ruby web servers.
* Something light, with minimal dependencies.
* Something which lends itself to structuring endpoints with clear responsibilities.

To fulfil these needs, I wrote [Sliver](https://github.com/pat/sliver). It is indeed built upon Rack - but that is its only dependency. While you can put all your logic in a single file if you really want, I've built it with the expectation that each API endpoint is handled by a separate class for maximum [SRP](https://en.wikipedia.org/wiki/Single_responsibility_principle)-friendliness.

    require 'rack'
    require 'sliver'

    app = Sliver::API.new do |api|
      api.connect :get, '/ping', StatusAction
    end

    class StatusAction
      # Get a few helper methods for handling requests
      include Sliver::Action

      def call
        # You can access local variables environment (your standard
        # env hash) and request (a Rack::Request object built from
        # that hash), and then construct your response accordingly:

        response.headers['Content-Type'] = 'application/json'
        response.status = 200
        response.body   = ['{"status":"OK"}']
      end
    end

    run app

Granted, that's an extremely simplistic example, but it provided the foundations I was after. Each endpoint can be moved into their own file, and the API routing can live in its own file too.

We've been using Sliver in production in a few apps over the last year, and that has prompted some healthy evolution of features. In Sliver itself, I've added the following:

* [Guards](https://github.com/pat/sliver#guards) for pre-endpoint behaviours, similar to before_action filters in Rails controllers
* [Processors](https://github.com/pat/sliver#processors) to transform endpoint responses - particularly useful to ensure consistent JSON/header output.
* [Path parameters](https://github.com/pat/sliver#path-parameters) to allow for ids and other details being part of the endpoint path.

We've not abandoned Rails, though - and so our APIs get mounted within a Rails app, which has led to a separate gem [Sliver::Rails](https://github.com/pat/sliver-rails) with additional features:

* Inherit from a core action class `Sliver::Rails::Action` (much like Rails' `ActionController::Base`), rather than including a module.
* [Strong parameters](https://github.com/pat/sliver-rails#parameters) so you can be clear about the parameters your endpoint expects to be dealing with.
* [Parse JSON bodies](https://github.com/pat/sliver-rails#json-requests) and make them available from the `params` variable, like Grape does.
* [Inbuilt JSON Processor](https://github.com/pat/sliver-rails#inbuilt-json-processor) for ensuring your responses are JSON-formatted.
* [JSON templating with Jbuilder](https://github.com/pat/sliver-rails#json-templates-and-exposed-variables) so you don't need to have your template defined with the endpoint behaviour.

With the JSON templating feature, I've added a [Decent Exposure](https://github.com/hashrocket/decent_exposure)-inspired syntax for exposing variables into the view templates. I like having a clear contract between endpoint and template as to what's being shared, and this is the _only_ way you can share data between the two in Sliver::Rails. Instance variables belong only to the endpoint instance.

Though using Sliver deeply in the past twelve months, we've adopted some patterns for files and directory structures:

    # app/apis/v1.rb
    class V1 < Sliver::API
      def initialize
        super do |api|
          api.connect :get, '/posts',     V1::Posts::Index
          api.connect :get, '/posts/:id', V1::Posts::Show
        end
      end
    end

    # app/apis/v1/standard_action.rb
    class V1::StandardAction < Sliver::Rails::Action
      def self.guards
        [V1::Guards::AuthenticationGuard]
      end

      def self.processors
        [Sliver::Rails::Processors::JSONProcessor]
      end

      def current_user
        # ...
      end
    end

    # app/apis/v1/posts/index.rb
    class V1::Posts::Index < V1::StandardAction
      use_template 'api/v1/posts/index'

      expose(:posts) { Post.order(:created_at => :desc) }
    end

    # within config/routes.rb
    mount V1.new => '/api/v1'

* APIs are subclasses of Sliver::API.
* Each version of an API gets its own routing file, which live in `app/apis` (for example: `app/apis/v1.rb`).
* Endpoints will inherit from a custom base class (similar to `ApplicationController`) which handle common logic (such as the current user, standard guards and processors).
* Endpoints are grouped by version and resource (in `app/apis/v1/posts`) and separated by their CRUD action, named to match the standard Rails action set (index, show, create, update, destroy).
* Views are kept in `app/views`, namespaced to match the endpoints (e.g. `app/views/api/v1/posts/index.jbuilder`).

These patterns are just what work for us at [Inspire9](http://inspire9dev.com), and while they're somewhat arbitrary, it helps make our code predictable and removes questions around where to put our endpoint classes and what they should be named. Also, because they're within the Rails `app` directory, they'll get treated as reloadable classes in a development environment.

In the future, it'd be neat to add different templating approaches, structures to encourage solid [json:api](http://jsonapi.org) support, and [Swagger](http://swagger.io) integration.

If you decide to give Sliver a go, do let me know - I realise there are plenty of options for building APIs in Ruby, but perhaps this approach works for you as well.
