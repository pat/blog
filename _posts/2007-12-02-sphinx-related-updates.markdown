---
title: "Sphinx-related Updates"
redirect_from: "/posts/sphinx_related_updates/"
categories:
  - plugins
  - search
  - sphinx
  - ruby
  - rails
---
Two Sphinx-related tidbits:

### Riddle

[Riddle](http://riddle.freelancing-gods.com) now has a tag in SVN for
the 0.9.8-r909 release of Sphinx - not that there were really any
functional changes compared to r871, besides the two extra match modes
(Full Scan and Extended 2 - the latter isn’t going to hang around for
long anyway).

### Thinking Sphinx

As well as supporting the above version of Sphinx, I’ve now added some
brief documentation to [Thinking Sphinx](http://ts.freelancing-gods.com)
that discusses attributes, sorting and delta indexes. To summarise
kinda-briefly:

#### Attributes

Attributes are defined in the define\_index block as follows:

    define_index do |index|
      index.has.created_at
      index.has.updated_at
      # Field definitions go here
    end

They can only be from the indexed model (not associations), and in line
with Sphinx’s limitations, must be either integers, floats or
timestamps.

#### Sorting

Ties in closely with attributes - as that’s all Sphinx will let you
order by. Use it in the same way as you would in a `find` call:

    Invoice.search :conditions => "expensive", :order => "created_at DESC"

Same approach works for the `:include` parameter (although this has
nothing to do with Sphinx itself).

#### Delta Indexes

Delta indexes track changes to model records between proper indexes (ie:
from the rake task thinking\_sphinx:index) - all they require is a
boolean field in the model’s table called `delta`, and for delta
indexing to be enabled as follows:

    define_index do |index|
      index.delta = true
      # Fields and attributes go here
    end

The one catch - at this point, delta indexes are one step off current,
as they get indexed before the current transaction to the database is
committed. This will get better soon, thanks to some help from Joost
Hietbrink and his colleagues at [YelloYello](http://www.yelloyello.com)
- once I find some free time, I’ll get that working much more neatly.
