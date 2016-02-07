---
title: "Anti-Definite"
redirect_from: "/posts/anti_definite/"
categories:
  - mysql
  - database
  - sorting
---
Just a quick post to highlight a MySQL function I’ve created that I’m
finding to be very useful (perhaps others will as well).

I love it when sorting ignores prefixes of ‘The’ or ‘A’ - definite or
indefinite articles, if you want the correct terms. To get this
happening within a SQL `SELECT` request is a bit tricky, but inspired by
[someone else’s
solution](http://www.arraystudio.com/as-workshop/how-to-sort-mysql-results-ignoring-definite-and-indefinite-articles-the-a-an.html)
(Ok, so I pretty much copied their code), I’ve created the following
function to make it a lot easier:

    CREATE FUNCTION ANTIDEFINITE(field VARCHAR(1024))
    RETURNS VARCHAR(1024) DETERMINISTIC
      RETURN CASE
        WHEN SUBSTRING_INDEX(field, ' ', 1) IN ('a', 'an', 'the')
          THEN CONCAT(SUBSTRING(field, INSTR(field, ' ') + 1),
          ', ', SUBSTRING_INDEX(field, ' ', 1))
        ELSE field
      END;

It works in MySQL 5.0 and 5.1 - I’m sure something similar could be
concocted for Postgres.

To use, just call the function on whichever fields you want in your
order clause, such as:

    SELECT *
    FROM posts
    ORDER BY ANTIDEFINITE(subject);

Or, via Rails:

    Post.find :all, :order => 'ANTIDEFINITE(subject)'

I’m not sold on the function name, though - it’s a bit long, but at
least it’s clear. If you’ve got a better suggestion, let me know.
