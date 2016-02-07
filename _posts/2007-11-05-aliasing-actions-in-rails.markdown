---
title: "Aliasing Actions in Rails"
redirect_from: "/posts/aliasing_actions_in_rails/"
categories:
  - ruby
  - rails
---
Code snippet for application.rb that makes life just a *little* easier
if multiple actions are doing exactly the same thing (both in the
controller and the view):

    def self.alias_action(existing, aliased)
      define_method(aliased.to_sym) do
        send(existing.to_sym)
        render :action => existing.to_s
      end
    end

</code>

And then in the appropriate controller (where `edit` is an existing
action, and `show` needs to be exactly the same):

    alias_action :edit, :show

</code>

I know this is a specialised use - but perhaps someone else out there is
doing something similar.

------------------------------------------------------------------------

<div class="comments">
<div class="comment-author">
<a href="http://drnicwilliams.com">Dr Nic</a> left a comment on 5 Nov,
2007:</div>

<div class="comment" markdown="1">
Hmm, I love where your heart is at. Perhaps

    def edit; show; end

Gets the trick done too :)

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 5 Nov,
2007:</div>

<div class="comment" markdown="1">
Ah, not quite Nic - as the view for the existing action needs to be
rendered as well - which is one extra line: `render :action => "show"`
for your example.

But yeah, it’s not saving many lines of code, I just find it a little
more elegant.

</div>
</div>

