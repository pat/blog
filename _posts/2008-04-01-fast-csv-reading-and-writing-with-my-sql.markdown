---
title: "Fast CSV reading and writing with MySQL"
redirect_from: "/posts/fast_csv_reading_and_writing_with_my_sql/"
categories:
  - mysql
  - sql
  - csv
  - import
  - export
---
I came across a handy way to import CSVs into MySQL the other day -
something that’s probably useful to other people. Pure MySQL too.

First, grab your CSV file, and remove the header line (into the
clipboard is recommended). Then open up MySQL via a shell of your
choice, and type something like the following:

    LOAD DATA LOCAL INFILE '/path/to/my_data.csv'
    INTO TABLE table_name
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    (column_a, column_b, column_c, column_d);

Obviously, put in the correct path to your csv file, the appropriate
table name, and the columns in the same order as they are in the file
(which is where your clipboard contents becomes useful). It is *damn*
fast. I barely blinked and it was done on a 50,000 record file. For
150,000, it took all of 10 seconds.

Of course, knowing this, I figured there’d be an equivalent way to get
the data out into CSV files as well. A quick search of MySQL’s site
revealed the following:

    SELECT column_a, column_b, column_c, column_d
    INTO OUTFILE 'path/to/my_data.csv'
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    FROM table_name;

More details are in the documentation - for both
[importing](http://dev.mysql.com/doc/refman/5.0/en/load-data.html) and
[exporting](http://dev.mysql.com/doc/refman/5.0/en/select.html#id812780).
