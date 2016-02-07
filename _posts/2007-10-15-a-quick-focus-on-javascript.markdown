---
title: "A Quick Focus on Javascript"
redirect_from: "/posts/a_quick_focus_on_javascript/"
categories:
  - javascript
  - html
---
Neat little refactoring trick for the day (as I’ve just recounted to the
<a href="irc://irc.freenode.net/roro">roro crew</a>)…

I found myself writing several `window.onload` event listeners in
javascript to set focus to the default text inputs on various pages.
It’s annoying, and doesn’t feel at all elegant, so to make it a little
cleaner, I wrote a single onload listener, which grabbed the last item
with the class ‘autofocus’, and set focus to that. So now all I need to
do for future pages is give the text input a class of ‘autofocus’.

Javascript code, with prototype:

    Event.observe(window, "load", function() {
      var last = $$(".autofocus").last();
      if (last) last.focus();
    });

Not so useful if you rarely have default text fields, but for the app
I’m working on, there’s a lot of different pages, hence why I’m quite
happy with the above solution.

------------------------------------------------------------------------

<div class="comments">
<div class="comment-author">
<a href="http://www.aestheticallyloyal.com">Anthony kolber</a> left a
comment on 15 Oct, 2007:</div>

<div class="comment" markdown="1">
You should try out jquery meng.  
The $() function is lovely. Faster than prototype and feels much more
elegant.

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">Pat</a> left a comment on 15 Oct,
2007:</div>

<div class="comment" markdown="1">
Yeah, would like to really get stuck into jQuery, but at the moment I’m
using the Autocompleter from scriptaculous, and a lightbox built off
prototype…

If I get bored, I might try rewriting those parts into jQuery, but
unlikely that’ll happen anytime soon.

</div>
<div class="comment-author">
<a href="http://germanforblack.com/">Ben Schwarz</a> left a comment on
17 Oct, 2007:</div>

<div class="comment" markdown="1">
You should probably apply that code to an event model like “domready”
rather than onload, as that encompasses images and external scripts
being available to the DOM.

Having said that, I believe that pure HTML can give you more advantage
rather than using Javascript here.

You may want to use another attribute (other than class) that has more
[semantic
meaning](http://www.w3.org/TR/html4/interact/forms.html#h-17.11)

</div>
</div>

