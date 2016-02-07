---
title: "validates_uniqueness_of_set"
redirect_from: "/posts/validates_uniqueness_of_set/"
categories:
  - ruby
  - rails
  - validation
---
Rails code snippet for the day:
[validates\_uniqueness\_of\_set](http://pastie.caboo.se/124537). Useful
for making sure each specific combination of the specified attributes is
unique. Example from the pastie:

    validates_uniqueness_of_set :first_name, :last_name

Just like the options it accepts, the code is very similar to
`validates_uniqueness_of` - and the few tests I’ve thrown at it are
handled without any problems.
