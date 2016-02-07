---
title: "Rspec'ing controllers"
redirect_from: "/posts/rspec'ing_controllers/"
categories:
  - rspec
  - bdd
  - testing
  - ruby
  - rails
---
I’m always trying to find a better way to write specs for my Rails apps
with [RSpec](http://rspec.rubyforge.org/) - it took a while for me to be
comfortable with writing model specs, but just recently, I’ve developed
a style of controller specs that I feel work well for me.

While it’s not too hard to write methods that automate some of the
repetitive side of things, it can be hard to do so in a manner that fits
RSpec’s DSL - but I’ve found the key to (my current style of) controller
specs is shared behaviours. An example of a few actions from the news
controller at [ausdwcon.org](http://ausdwcon.org):

    describe NewsController, "index action" do
      before :each do
        @method = :get
        @action = :index
        @params = {}
      end

      it_should_behave_like "Public-Access Actions"

      it "should paginate the results" do
        @news = []
        News.stub_method(:paginate => @news)

        get :index

        News.should have_received(:paginate)
        assigns[:news].should == @news
      end

      it "should set the title to 'News'" do
        News.stub_method(:paginate => [])

        get :index

        assigns[:title].should == "News"
      end
    end

    describe NewsController, "new action" do
      before :each do
        @method = :get
        @action = :new
        @params = {}
      end

      it_should_behave_like "Admin-Only Actions"

      it "should set the title to 'News'" do
        controller.current_user = User.stub_instance(:admin? => true)

        get :new

        assigns[:title].should == "News"
      end
    end

You can find the full spec for the controller on
[pastie.caboo.se](http://pastie.caboo.se/127883). The shared behaviors -
‘Public-Access Actions’ and ‘Admin-Only Actions’ - are (at least for the
moment) kept in my [spec\_helper.rb](http://pastie.caboo.se/127880) file
- a sample of which is below:

    describe "Admin-Only Actions", :shared => true do
      it "should not be accessible without authentication" do
        @controller.current_user = nil

        send @method, @action, @params

        response.should be_redirect
        response.should redirect_to(new_session_url)
      end

      it "should not be accessible by a normal user" do
        @controller.current_user = User.stub_instance(:admin? => false)

        send @method, @action, @params

        response.should be_redirect
        response.should redirect_to(new_session_url)
      end

      it "should be accessible by an admin user" do
        @controller.current_user = User.stub_instance(:admin? => true)

        send @method, @action, @params

        response.should_not redirect_to(new_session_url)
      end
    end

Firstly - the not so nice stuff: the use of instance variables to
communicate the method, action and parameters of requests to the shared
behaviours. It’s not ideal, and apparently there’s plans to add
arguments to the `it_should_behave_like` method, but for the moment it
does the job.

I’m using [Pete Yandell’s](http://notahat.com/)
[NotAMock](http://notamock.rubyforge.org/) for my stubbing - albeit with
a few modifications of my own (which may make it back into the plugin
itself at some point). I also use my own
[ActiveMatchers](http://am.freelancing-gods.com) - but that’s more
focused on models. It’s also not really feature-complete, but if you
like what it offers, feel free to use it.

Oh, and the main caveat? This is my current way of spec’ing controllers
- and it’s vastly better than the minimal specs I was writing before
this - but it may/will change. I don’t even know if my style is ‘best
practice’ - I’m putting them online to get feedback and provoke
discussion. So please feel free to critique.

------------------------------------------------------------------------

<div class="comments">
<div class="comment-author">
diwakar left a comment on 24 Apr, 2009:</div>

<div class="comment" markdown="1">
If you have mentioned the controller it would have been more helpful

</div>
</div>

