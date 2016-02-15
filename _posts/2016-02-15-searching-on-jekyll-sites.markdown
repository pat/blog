---
title: "Searching on Jekyll Sites"
categories:
  - search
  - jekyll
  - paas
  - saas
---

Last year, I shifted my blog over from an aging Rails 2.3 app to a Jekyll site powered by GitHub Pages. I also gained a shiny new design courtesy of my excellent and talented friend [Mark Brown](http://www.yellowshoe.com.au) - thanks Mark!

I've certainly appreciated the switch with the simple power of Jekyll, but I anguished over the lack of server-side search. Sure, I don't think it was ever that popular a feature on my old blog, but given a lot of my [open source work](https://github.com/pat/thinking-sphinx) and my Heroku Add-on side business [Flying Sphinx](http://info.flying-sphinx.com) is search-related, I didn't want to lose it...

So I went and built a whole new web app to power search for my static site (yes, using Flying Sphinx). Overkill? Most definitely! But perhaps others out there would like search for their Jekyll-powered sites, so I've turned it into a paid offering: [Drumknott](https://drumknottsearch.com).

The [documentation](https://drumknottsearch.com/documentation) covers how to use it pretty well, so I won't duplicate that here, but it's not too complicated: a bit of Javascript on your site and a command-line tool to update your page data. That's it!

It's also worth noting that the code that underpins the service is [open source](https://github.com/pat/drumknott-server). I don't feel I'll lose any customers from this (trust me, it's much cheaper for you to pay me the small price of $3 USD/month than it would be to host it yourself), and perhaps others can improve on my code and submit patches! There are also some nice things in the code that I'll write about in the near future.

Perhaps I'll be the only one to use the service - and if so, that's fine. I've got something to power the search on this blog, and I've enjoyed putting it all together and finding nice ways to structure the billing code. Any additional customers will just be a nice bonus. That said, if you think it's useful, please do try it out!
