---
title: "Combustion - Better Rails Engine Testing"
redirect_from: "/posts/combustion_better_rails_engine_testing/"
categories:
  - ruby
  - rails
  - engines
  - testing
---
I spent a good part of last month writing my first Rails engine -
although it’s not yet released and for a client, so I won’t talk about
that too much here.

Very quickly in the development process, I was looking around on how to
test Rails engines. It seemed that, beyond some basic unit tests, having
a full Rails application within your test or spec directory was the
accepted approach for integration testing.

That felt kludgy and bloated to me, so I decided to try something a
little different.

The end goal was full stack testing in a clear and manageable fashion -
writing specs within my spec directory, not a bundled Rails app’s spec
directory. Capybara’s DSL would be nice as well.

This, of course, meant having a Rails application to test through - but
it turns out you can get away without the vast majority of files that
Rails generates for you. Indeed, the one file a Rails app expects is
`config/database.yml` - and that’s only if you have ActiveRecord in
play.

Enter [Combustion](https://github.com/pat/combustion) - my minimal Rails
app-as-a-gem for testing engines, with smart defaults for your standard
Rails settings.

### Setting It Up

A basic setup is as follows:

-   Add the gem to your gemspec or Gemfile.
-   Run the generator in your engine’s directory to get a small Rails
    app stub created: `combust` (or `bundle exec combust` if you’re
    referencing the git repository instead).
-   Add `Combustion.initialize!` to your `spec/spec_helper.rb`
    (currently only RSpec is supported, but shouldn’t be hard to patch
    for TestUnit et al).

Here’s a sample `spec_helper`, mixing in Capybara as well:

    require 'rubygems'
    require 'bundler'

    Bundler.require :default, :development

    require 'capybara/rspec'

    Combustion.initialize!

    require 'rspec/rails'
    require 'capybara/rails'

    RSpec.configure do |config|
      config.use_transactional_fixtures = true
    end

### Putting It To Work

Firstly, you’ll want to make sure you’re using your engine within the
test Rails application. The generator has likely added the hooks we need
for this. If you’re adding routes, then edit
`spec/internal/config/routes.rb`. If you’re dealing with models, make
sure you add the tables to `spec/internal/db/schema.rb`. The
[README](https://github.com/pat/combustion/blob/master/README.textile)
covers this a bit more detail.

And then, get stuck into your specs. Here’s a really simple example:

    # spec/controllers/users_controller_spec.rb
    require 'spec_helper'

    describe UsersController do
      describe '#new' do
        it "runs successfully" do
          get :new

          response.should be_success
        end
      end
    end

Or, using Capybara for integration:

    # spec/acceptance/visitors_can_sign_up_spec.rb
    require 'spec_helper'

    describe 'authentication process' do
      it 'allows a visitor to sign up' do
        visit '/'

        click_link 'Sign Up'
        fill_in 'Name',     :with => 'Pat Allan'
        fill_in 'Email',    :with => 'pat@no-spam-please.com'
        fill_in 'Password', :with => 'chunkybacon'
        click_button 'Sign Up'

        page.should have_content('Sign Out')
      end
    end

And that’s really the core of it. Write the specs you need to test your
engine within the context of a full Rails application. If you need
models, controllers or views in the internal application to fully test
out your engine, then add them to the appropriate location within
`spec/internal` - but only add what’s necessary.

### Rack It Up

Oh, and one of my favourite little helpers is this: Combustion’s
generator adds a `config.ru` file to your engine, which means you can
fire up your test application in the browser - just run `rackup` and
visit <http://localhost:9292>.

### Caveats

As already mentioned, Combustion is built with RSpec in mind - but I
will happily accept patches for TestUnit as well. Same for Cucumber -
should work in theory, but I’m yet to try it.

It’s also written for Rails 3.1 - it may work with Rails 3.0 with some
patches, but I very much doubt it’ll play nicely with anything before
that. Still, feel free to investigate.

And it’s possible that this could be useful for integration testing for
libraries that aren’t engines. If you want to try that, I’d love to hear
how it goes.

### Final Notes

So, where do we stand?

-   You can test your engine within a full Rails stack, without a full
    Rails app.
-   You only add what you *need* to your Rails app stub (that lives in
    `spec/internal`).
-   Your testing code is DRYer and easier to maintain.
-   You can use standard RSpec and Capybara helpers for
    integration testing.
-   You can view your test application via Rack.

I’m not the first to come up with this idea - after I had finished
Combustion, it was pointed out to me that [Kaminari’s test
suite](https://github.com/amatsuda/kaminari/blob/master/spec/fake_app.rb)
does a similar thing (just not extracted out into a separate library).
It wouldn’t surprise me if others have done the same - but in my
searching, I kept coming across well-known libraries with full Rails
apps in their test or spec directories.

If you think Combustion could suit your engine, please give it a spin -
I’d love to have others kick the tires and ensure it works in a wider
set of situations. Patches and feedback are most definitely welcome.

------------------------------------------------------------------------

<div class="comments">
<div class="comment-author">
<a href="http://blog.plataformatec.com.br">José Valim</a> left a comment
on 7 Sep, 2011:</div>

<div class="comment" markdown="1">
Hey Pat!

I am likely the main responsible for the practice of bundling Rails apps
inside gems. It started with “Crafting Rails Applications” and the
target was to make very clear what is happening when you boot your
application and when config/application.rb and config/environment.rb are
loaded (it is explained with a dummy app right in the first chapter!).

That said, I think combustion provides a nice alternative to the problem
for those who want completely hide away the Rails initialization
process.

Just one note: I disagree that bundling a Rails app is brittle, it does
exactly the same as combution, except that it does it explicitly.
However, I agree that bundling the whole Rails app can be considered
“bloat” but you really don’t need all those files. You can get away by
keeping only config/{boot,application,environment}.rb (plus the
database.yml if you are using AR), which is basically what combustion
defines.

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 7 Sep,
2011:</div>

<div class="comment" markdown="1">
Hi José

I realise there’s not a huge difference in the two approaches (and I had
someone point out you’d made the full-app suggestion in your book
halfway through developing Combustion – I should probably get myself a
copy to read!).

I didn’t actually intend for Combustion to end up being a full Rails
app, I just wanted full-stack testing with as little code as possible -
and just added things bit by bit until it worked.

And yeah, brittle isn’t quite the right description - I got a little
carried away.

</div>
<div class="comment-author">
Dan Croak left a comment on 8 Sep, 2011:</div>

<div class="comment" markdown="1">
Very cool, Pat. Take a look at http://github.com/thoughtbot/diesel and
http://github.com/thoughtbot/appraisal for some other ideas about
testing engines and testing different versions of Rails, respectively.

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 8 Sep,
2011:</div>

<div class="comment" markdown="1">
Very cool, thanks for sharing those Dan - I’m surprised I never found
diesel in my searching. Appraisal reminds me of a gem I wrote some time
ago for the same purpose - Ginger -
https://github.com/freelancing-god/ginger - but that was before Bundler,
and Appraisal seems a much cleaner approach now.

</div>
<div class="comment-author">
<a href="http://nepalonrails.tumblr.com">Millisami</a> left a comment on
19 Sep, 2011:</div>

<div class="comment" markdown="1">
Nice setup to test the engine.  
But there is built in engine generator in Rails 3.1 with the following
command.

rails plugin new my\_engine —mountable

This command also generates a dummy rails app to test against. Its
described in Ryan Bigg’s Rails3InAction book. Though it generates the
test setup for TestUnit, but its easy to tweak for RSpec too.

Did you build Combustion just to ease the setup or find anything with
the built-in plugin generator?

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 19 Sep,
2011:</div>

<div class="comment" markdown="1">
I’ve not used the built-in engine/plugin generator in a long, long time
(before engines existed) - Combustion was just built to make testing of
engines simpler and DRYer.

It’s no surprise that the generator adds a dummy app, since that is the
established approach for testing engines.

</div>
<div class="comment-author">
Brad left a comment on 29 Jan, 2013:</div>

<div class="comment" markdown="1">
New link to README: https://github.com/pat/combustion

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 29 Jan,
2013:</div>

<div class="comment" markdown="1">
Thanks Brad, just updated the post with the newer link.

</div>
</div>

