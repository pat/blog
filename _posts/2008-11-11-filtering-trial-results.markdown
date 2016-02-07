---
title: "Filtering Trial Results"
redirect_from: "/posts/filtering_trial_results/"
categories:
  - politics
  - australia
  - internet
  - censorship
---
The Australian Government’s contentious ‘Clean Feed’ internet censorship
proposal has got some media attention lately - and by and large, it’s
been rightly critical of Senator Conroy’s plans. If you’re not familiar
with it, I recommend you read [my
letters](http://freelancing-gods.com/posts/internet_censorship_in_australia)
[to
Conroy](http://freelancing-gods.com/posts/correspondance_on_censorship)
and peruse [nocleanfeed.com](http://nocleanfeed.com/).

In the middle of last year, the previous Government commissioned a
closed environment testing trial. The results of these were released
recently, and the values have been used by both sides to tout the
usefulness/uselessness of filters. Handily, these results are [available
to the public](http://www.acma.gov.au/WEB/STANDARD/pc=PC_311316), so
I’ve skimmed through the extensive PDF - although I claim no solid
understanding of it all - to figure out where the figures are from.

Firstly, a few facts:

-   Six different filtering approaches were tried (with the codenames
    Alpha, Beta, Gamma, Delta, Theta and Omega).
-   These trials were conducted on a purpose-built network.
-   The network is similar in scale to a Tier 3 ISP.
-   The trials covered speed changes, the effectiveness of blocking
    blacklisted material, and the valid sites blocked incorrectly.
-   Most filters were only tested against HTTP and HTTPS traffic. Gamma
    and Omega were also applied to emails, and Delta skipped on HTTPS.

A full grid of numbers is at the bottom of the post, but let’s go
through a few comparisons.

### Speed vs Blocking

<img src="http://img.skitch.com/20081111-e7c5rs2tsjmbqetr8t3dpd4igd.jpg" alt="Speed vs Blocking" />

The speed results here are really mixed. One (Delta) doesn’t drop much
at all, but two (Alpha and Gamma) are horrific. All filters manage to
block at least 87% of the blacklist - but only Beta comes really close,
with 98% (losing a third of the speed in the process though).

### Speed vs False Positives

<img src="http://img.skitch.com/20081111-kt84w9j9uj7r9j4bfsc9xmu7p1.jpg" alt="Speed vs False Positives" />

Note that the scale on the Y Axis drops a bit, but we still get another
set of mixed results. None of them are perfect on the false-positives
front, and the closest is Gamma on 1.3% - but that comes with severly
limited speeds. And really - there are a *lot* of websites out there.
Even 1% covers a fair chunk of the net.

### Blocking vs False Positives

<img src="http://img.skitch.com/20081111-xf8gey3a7j2xdb8d5hbrt84935.jpg" alt="Blocking vs False Positives" />

Here there’s something of a trend, although you have to be looking for
it: better blocking effectiveness means a higher number of false
positives. That’s not good, people.

### Takeaways?

There’s really not that much to work off here, no matter what side of
the fence you’re on. The main things to keep in mind are:

-   None of the solutions are perfect.
-   All had issues with false-positives
-   This was done on something approaching a Tier 3 ISP - will the
    performance speeds decrease if we applied these filters on a Tier 1
    or 2 ISP? My money’s on yes.
-   It wasn’t Conroy who commissioned this study, so it can’t be pinned
    against him.
-   Delta, which is arguably the only viable filter judging by
    performance, still missed 9% of the blacklisted sites.
-   None of the filters were tested against newsgroups,
    IM (Instant Messaging), or peer-to-peer traffic. I’d imagine
    HTTP/HTTPS filters are relatively easy, so expecting the same
    performance and effectiveness for other protocols sounds like a pipe
    dream to me.

### Raw Numbers

|*.   |*\\3. Performance |\_\\2. Effectiveness |  
|*. Filter |*. PPI (Passive Performance Index) |*.
API (Active Performance Index) |*. CPI (Change In Performance Index) |*.
BRI (Blocking Rate Index) |*. OBI (Overblocking Index) |  
| Alpha | 92% | 16% | 17% | 90% | 2.6% |  
| Beta | 99% | 67% | 68% | 98% | 7.5% |  
| Gamma | 98% | 14% | 14% | 87% | 1.3% |  
| Delta | 99% | 98% | 100% | 91% | 2.4% |  
| Theta | 78% | 76% | 99% | 95% | 7.8% |  
| Omega | 101% | 79% | 78% | 94% | 2.9% |

Glossary of sorts: **PPI** (Passive Performance Index) is the relative
speed when a filter is attached but not running. **API** (Active
Performance Index) is the relative speed when the filter is running.
**CPI** (Change In Performance Index) is API when using PPI as the
reference point (instead of uninhibited network speeds). **BRI**
(Blocking Rate Index) is the percentage of blacklisted sites stopped,
and **OBI** (Overblocking Index) is the percentage of friendly sites
overzealously blocked.
