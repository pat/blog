---
title: "An Introduction to Frozen String Literals"
categories:
  - ruby
  - rails
  - programming
  - strings
---

In this post I am running through the basic concepts of literals, strings, and the benefits of frozen objects in Ruby. If you feel like you understand this, jump straight on over to [part two](friendly-frozen-string-literals.html) which covers the new Frozen String Literal feature in Ruby 2.3 and beyond.

## What are Literals?

In Ruby, everything is an object, and objects have a standard way of being generated: via the `new` constructor method on a class:

    user = User.new

However, in some cases there are more natural - thus, _literal_ - expressions to create basic objects, such as numbers, symbols, arrays, hashes, and ranges:

    cost  = 19.95
    array = [1, 2, 3]
    range = 1..3
    hash  = {
      :key => :value
    }

## What are Strings (and String Literals)?

Strings are essentially ordered collections of characters, and in Ruby (and many other languages) they're represented literally by using quotes or other bracketing syntax:

    # String literals
    "thank you"
    'danke'
    <<TEXT
      ngoon godgin
    TEXT
    "asante #{name}"
    %Q{arigato}
    %q[orkun geran]

    # Array literal of single-word string literals:
    %w[ obrigado merci xiè-xie ]

Strings defined in some other, more computed manner don't fall into this category. For example, the string that's created from calling `join` on an Array:

    [1, 2].join(" & ") #=> "1 & 2"

Or from joining two string literals together with a `+`:

    "1" + "2" #=> "12"

Or even from using the constructor `String.new`.

## What are Frozen Objects?

The term 'frozen' is Ruby's way of saying immutable, which is a technical way of saying something cannot be changed. A frozen object in Ruby cannot be modified in any way - if a modification is attempted, an exception will be raised.

Most objects in Ruby default to being mutable (changeable), including strings:

    "gelato".frozen? #=> false

If you want to ensure an object cannot be changed, you can freeze it:

    lunch = "gelato"
    lunch.freeze
    lunch.frozen? #=> true

This process cannot be reversed - once an object is frozen in Ruby, it will remain frozen.

The benefit of this is that you can then rely on certain objects being consistent in their value, no matter where they're used and what other parts of code may try to do. This means fewer assumptions in your code, and that is a Good Thing.

## Why Freeze Strings?

In Ruby, whenever you have a statement defining a string as a literal, it's a new object, with its own space in memory. `"a"` in one line of your code and `"a"` in another have the same contents, but are separate. And if those statements are called more than once, then every time they're called, new strings are allocated in memory.

    def hello
      "greetings"
    end

    # This returns five different object ids, for five strings with identical contents.
    5.times.collect { hello.object_id }

To avoid extra objects, you could extract common strings into constants:

    HELLO = "greetings"

    def hello
      HELLO
    end

    # This returns five identical object ids, all for the same string.
    5.times.collect { hello.object_id }

This is great, because we only need to store one instance of the string in memory, no matter how many times it's used. The issue here, though, is that the string could be modified by one use, and that affects all future uses:

    HELLO = "greetings"

    def hello
      HELLO
    end

    # This appends my name to the end of the string
    puts hello << " Pat"
    # Future calls have that modification.
    puts hello #=> "greetings Pat"

This is a contrived example, but imagine code in a complex app behaving like this, and how hard that might be to track down. So, let's use Ruby's ability to freeze an object - stopping it from being modified:

    HELLO = "greetings".freeze

    def hello
      HELLO
    end

    # This raises a RuntimeError: can't modify frozen String
    puts hello << " Pat"

Any attempts to modify that re-usable string results in an exception, which is great - our tests will highlight such invalid uses, and we can find other ways to get the results we're after:

    HELLO = "greetings".freeze

    def hello
      HELLO
    end

    # Let's create a new string that includes my name:
    puts "#{hello} Pat" #=> "greetings Pat"
    # And then, `hello` remains consistent:
    puts hello #=> "greetings"

Using constants of frozen strings is useful for performance and reliable behaviour - but it can get tiresome doing this all the time. However, Ruby 2.3 introduced a new (optional) behaviour: to treat all string literals as frozen. I cover this behaviour in [my next post](friendly-frozen-string-literals.html).
