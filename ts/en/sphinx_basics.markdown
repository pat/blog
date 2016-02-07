---
layout: ts_en
title: Sphinx Basics
---


An Introduction to Sphinx
-------------------------

### What is Sphinx?

Sphinx is a search engine. You feed it documents, each with a unique
identifier and a bunch of text, and then you can send it search terms,
and it will tell you the most relevant documents that match them. If
you’re familiar with Lucene, Ferret or Solr, it’s pretty similar to
those systems. You get the daemon running, your data indexed, and then
using a client of some sort, start searching.

When indexing your data, Sphinx talks directly to your data source
itself – which must be one of MySQL, PostgreSQL, or XML files – which
means it can be very fast to index (if your SQL statements aren’t too
complex, anyway).

### Sphinx Structure

A Sphinx daemon (the process known as searchd) can talk to a collection
of indexes. Each index tracks a set of documents, and each document is
made up of fields and attributes. While in other areas of software you
could use those two terms interchangeably, they have distinctly
*different* meanings in Sphinx.

### Fields

Fields are the content for your search queries – so if you want words
tied to a specific document, you better make sure they’re in a field in
your index. They are only string data – you could have numbers and dates
and such in your fields, but Sphinx will only treat them as strings,
nothing else.

### Attributes

Attributes are used for sorting, filtering and grouping your search
results. Their values do not get paid any attention by Sphinx for search
terms, though, and they’re limited to the following data types:
integers, floats, datetimes (as Unix timestamps – and thus integers
anyway), booleans, and strings. Take note that string attributes are
converted to ordinal integers, which is especially useful for sorting,
but not much else.

### Multi-Value Attributes

There is also support in Sphinx to handle arrays of attributes for a
single document – which go by the name of multi-value attributes.
Currently, only integers are supported, so this isn’t quite as flexible
as normal attributes, but it’s worth keeping in mind.
