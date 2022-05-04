---
title: "Building services with a conscience"
categories:
  - tools
  - work
  - society
  - community
  - culture
  - ethics
  - security
  - privacy
  - sustainability
  - startups
  - values
  - challenges
excerpt: "Building software-as-a-service with a conscience is something that I've been mindful of while creating Calm Calendar. I wanted to share where things currently stand."
---
Building software-as-a-service with a conscience is something that I've been mindful of while creating [Calm Calendar](https://calmcalendar.com). I know I've still got a long way to go in this journey, but I wanted to share a bit of my thinking as things currently stand.

### Privacy and Security

I'd like to think that privacy is just common sense, but especially since I'm dealing with customers' calendars - which contain sensitive information in both personal and work contexts - I want to stress how important this is.

So: even though I can access a lot of details about calendars and events, I only store what's absolutely necessary for processing. There is a trade-off in that it makes logging and reporting details to customers more tricky, but I think I have the balance right. When I have customers reporting bugs and edge-cases to me, I ask for a specific example - this helps my investigations focus on single pieces of personal data, to avoid being exposed to anything that isn't relevant.

In a previous attempt at building Calm Calendar, I was using a third-party service to integrate with customer calendars - but this meant that service was the controlling party of my customers' data. While it saved me a heap of effort, it also meant that I couldn't be fully responsible for how that data was accessed or stored - so instead, I rewrote CC to handle these calendar connections itself. Again, it's a trade-off, but I don't regret spending the extra time to limit the risk of data misuse.

And a feature I didn't launch with but am very glad to have added is the ability to connect calendar accounts in read-only mode (when that's appropriate for the account) - thus ensuring that Calm Calendar only requests the absolutely necessary permissions for accessing customer data.

### Hosting and Infrastructure

When it comes to the right place to host a site, it very much feels like it's a trade-off between simplicity and ethics.

All the big tech companies have, at best, questionable ethics. It feels like Amazon is the worst of the bunch, given how they treat their warehouse staff (but also, their unwillingness to share information about energy sources of their data centres, and anti-competitive behaviour more generally). That said, Microsoft and Google are a _long_ way from perfect too.

Alongside these concerns, I also want to prioritise data centres powered by renewable energy, and what would be ideal is something outside of the US (because the approach to data privacy by their government agencies has been disturbing).

But, I also don't want to have to worry too much about managing infrastructure - I've become quite accustomed to the ease of Heroku. Sadly there doesn't seem to be a perfect solution in this space - so many managed hosting options are built on top of big tech cloud infrastructure, and the less-managed solutions require significantly more time, effort and money (and infrastructure/operations skills that I don't have to the level that would be required).

So my pragmatic solution thus far has been to use [Render](https://render.com). They're managed hosting (yay), built on top of Google (boo), powered by renewable energy (yay) when using Google's Oregon data centre in the US (boo). Despite some of their tooling being not as mature as Heroku, their support has been super helpful.

Perhaps one day Calm Calendar will have enough customers that I can justify the time and money to implement a better solution - something without any big tech company involvement, powered by renewables, in a country that has a much better track record at protecting and respecting privacy. But this is a bootstrapped venture - I don't see such a change happening any time soon!

### Rebalancing Power

I want to be especially direct on this point: I live in Naarm, on the stolen land of the Wurundjeri people of the Kulin nations - land more commonly known as Melbourne, Australia. I am creating financial wealth for myself and - I hope with Calm Calendar, creating value for others - but that cannot be separated from the broader context of our society. We live and work and play in colonial and [capitalist](https://twitter.com/jasonhickel/status/1515977488110915587) systems, both of which are predicated on denying people's humanity.

And, as devastating as it is, this largely feels unavoidable - but I don't want to just accept it blindly. One _very_ small thing I'm doing is sending 5% of all Calm Calendar revenue (not profit) to [Pay the Rent](https://paytherent.net.au) which direct empowers and supports local First Nations communities. Perhaps there are other similar organisations for other parts of the world?

Should Calm Calendar grow into a business where I employ others, then I feel there's greater opportunities to enact policies and support systems that push back against harmful systems and institutions. I'll certainly be pondering further on what else can be done even in this early stage of the venture.

---

These feel like the key considerations thus far, but I know I could do better - I hope they at least get other people thinking, and provide a spark of inspiration. If anyone has suggestions, or areas in which they challenge me to be better, I'm very keen to hear them!
