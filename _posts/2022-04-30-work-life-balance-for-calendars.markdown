---
title: "Calm Calendar: work/life balance for calendars"
categories:
  - tools
  - productivity
  - time
  - calendars
  - work
excerpt: "Introducing a service that provides cross-platform work/life balance for your calendars: Calm Calendar - https://calmcalendar.com"
---
I'm a little late in mentioning it here, but I wanted to introduce a new service I've built for work/life balance within your online calendars: [Calm Calendar](https://calmcalendar.com).

The main use is for synchronising events from personal calendars to your work calendar while redacting details, so your colleagues know you're busy but don't get to see the finer details - perfect for situations where colleague calendars are shared automatically. That said, you can also choose to keep details public, and you can synchronise as many calendars in whatever configuration you like - it's just that personal-to-work is what resonates with most people (and it's what prompted me to build it).

There are other services out there like this, but it seems they're all Google-only. I use a mixture of calendar services myself, and I'm no fan of closed ecosystems, so having Calm Calendar support a variety of provides was always essential. At this point in time, Microsoft (Outlook, Office365, Exchange), Apple, Fastmail, and other CalDAV services are all supported, along with read-only ICS calendar URLs. Events can be synchronised in a cross-platform manner - for example: if you want personal Apple events copying into a Microsoft work account, <abbr title="Calm Calendar">CC</abbr> can do that for you.

---

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Finally time to share a little service I&#39;ve built:<br><br>Calm Calendar - work/life balance for your calendars, where it synchronises events from one/many calendars to others, redacting details.<br><br>Supports Google, Apple, Outlook, Exchange, Fastmail + CalDAV. 😎<a href="https://t.co/SDcZpwezPX">https://t.co/SDcZpwezPX</a></p>&mdash; Pat Allan (@pat) <a href="https://twitter.com/pat/status/1477909663869923329?ref_src=twsrc%5Etfw">January 3, 2022</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

Calm Calendar was actually [launched publicly](https://twitter.com/pat/status/1477909663869923329) back at the start of January 2022. Since then I've received a tonne of great feedback, and have made significant performance improvements and bug fixes - plus it's also wonderful to see the number of paying customers gradually creep upwards. Still, I'm keeping it cheap: it's only $3/month (with the option to pay annually as well as monthly).

I actually built the first version of this a few years ago, but it never got to the point of being released to the public. In this original approach, I was using a third-party tool to integrate with all the different calendar services - and this made things a lot easier, but it also raised the significant issue that this third-party was actually in control of customer data, rather than myself. This was far from ideal from privacy and security perspectives - customer data is extremely important, especially when it comes to both personal and work calendars. So I held off on launching, and got distracted by other projects (as well as a global pandemic).

The pandemic lockdowns, however, had the advantage of giving me the time to revisit this idea and learn how to interact with each calendar service's APIs directly - and so I rewrote Calm Calendar from scratch with this new, more secure approach providing a solid foundation.

I've got a constantly-growing list of features and improvements that I'm gradually working through, and there's also regular occurrences of finding (and then fixing CC to handle) interesting edge cases with new customers. One particular feature that I've been very happy to add this past month is team/organisation subscriptions, so one person can sign up to pay, and then colleagues just get added to that subscription (they can opt-in automatically, or it can be invite-only). This makes it super easy for companies to offer it to their staff without needing to wrangle multiple invoices/reimbursements.

---

There's certainly more thoughts to share about Calm Calendar - I'm keen to talk about my approach to building a responsible tool with a conscience, and about the tech stack and infrastructure involved. I'll follow up with those blog posts soon, but in the meantime, if [Calm Calendar](https://calmcalendar.com) sounds useful, please do give it a shot - and let me know what's good and what could be better!
