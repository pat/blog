---
title: "script/nginx"
redirect_from: "/posts/script_nginx/"
categories:
  - nginx
  - ruby
  - rails
  - passenger
---
This morning I decided to get [Nginx](http://wiki.nginx.org/Main) and
[Passenger](http://modrails.com/) set up in my local dev environment. I
needed an easier way to test of [Thinking
Sphinx](http://ts.freelancing-gods.com) in such environments, but also,
I find Nginx configuration syntax so much easier than Apache.

And of course, if I’ve got these components there, it would be great to
use them to serve my development versions of rails applications, much
like script/server. So I’ve got a script/nginx file that manages that as
well. Sit tight, and let’s run through how to make this happen on your
machine.

### Be Prepared to Think

Firstly, a couple of notes on my development machine - I’m running Snow
Leopard, and I compile libraries by source. No MacPorts, no custom
versions of Ruby (yet). So, you may need to tweak the instructions to
fit your own setup.

### Installing Passenger

Before we get to Nginx, you’ll want the Passenger gem installed first.

    sudo gem install passenger

You’ll also need to compile Passenger’s nginx module (keep an eye on the
file path below - yours may be different):

    cd /Library/Ruby/Gems/1.8/gems/passenger-2.2.5/ext/nginx
    sudo rake nginx

### Installing Nginx

Nginx requires the [PCRE](http://www.pcre.org) library, so that adds an
extra step, but it’s nothing too complex. Jump into Terminal or your
shell application of choice, create a directory to hold all the source
files, and step through the following commands (initially sourced from
[instructions](https://wincent.com/wiki/Installing_nginx_0.7.61_on_Mac_OS_X_10.6_Snow_Leopard)
by [Wincent Colaiuta](https://wincent.com)):

    curl -O \
      ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-7.9.tar.bz2
    tar xjvf pcre-7.9.tar.bz2
    cd pcre-7.9
    ./configure
    make
    make check
    sudo make install

That should be PCRE taken care of - I didn’t have any issues on my
machine, hopefully it’s the same for you. Next up: Nginx itself. Grab
the source:

    curl -O \
      http://sysoev.ru/nginx/nginx-0.7.62.tar.gz
    tar zxvf nginx-0.7.62.tar.gz
    cd nginx-0.7.62

Let’s pause for a second before we configure things.

Even though the focus is having Nginx working in a local user setting,
not system-wide, I wanted the default file locations to be something
approaching Unix/OS X standards, so I’ve gone a bit crazy with
configuration flags. You may want to alter them to your own personal
tastes:

    ./configure \
      --prefix=/usr/local/nginx \
      --add-module=/Library/Ruby/Gems/1.8/gems/passenger-2.2.5/ext/nginx \
      --with-http_ssl_module \
      --with-pcre \
      --sbin-path=/usr/sbin/nginx \
      --conf-path=/etc/nginx/nginx.conf \
      --pid-path=/var/nginx/nginx.pid \
      --lock-path=/var/nginx/nginx.lock \
      --error-log-path=/var/nginx/error.log \
      --http-log-path=/var/nginx/access.log

And with that slightly painful step out of the way, let’s compile and
install:

    make
    sudo make install

And just to test that Nginx is happy, run the following command:

    nginx -v

Do you see the version details? Great! (If you don’t, then review the
last couple of steps - did anything go wrong? Do you have the passenger
module path correct?)

### Configuring for a Rails App

The penultimate section - let’s create a simple configuration file for
Rails applications, which can be used by our `script/nginx` file. I
store mine at `/etc/nginx/rails.conf`, but you can put yours wherever
you like.

    daemon off;

    events {
      worker_connections  1024;
    }

    http {
      include /etc/nginx/mime.types;

      # Assuming path has been set to a Rails application
      access_log            log/nginx.access.log;

      client_body_temp_path tmp/nginx.client_body_temp;
      fastcgi_temp_path     tmp/nginx.client_body_temp;
      proxy_temp_path       tmp/nginx.proxy_temp;

      passenger_root /Library/Ruby/Gems/1.8/gems/passenger-2.2.5;
      passenger_ruby /usr/bin/ruby;

      server {
        listen      3000;
        server_name localhost;

        root              public;
        passenger_enabled on;
        rails_env         development;
      }
    }

### script/nginx

The final piece of the puzzle - the `script/nginx` file, for the Rails
app of your choice:

    #!/usr/bin/env bash
    nginx -p `pwd`/ -c /etc/nginx/rails.conf \
      -g "error_log `pwd`/log/nginx.error.log; pid `pwd`/log/nginx.pid;";

Don’t forget to make it executable:

    chmod +x script/nginx

If you run the script right now, you’ll see a warning that Nginx can’t
write to the global error log, but that’s okay. Even with that message,
it uses a local error log. I’ve granted full access to the global log
just to avoid the message, but if you know a Better Way, I’d love to
hear it.

    sudo chmod 666 /var/nginx/error.log

Head on over to [localhost:3000](http://localhost:3000) - and, after
Passenger’s warmed up, your Rails app should load. Success!

### Known Limitations

-   The environment is hard-coded to development. If this is annoying,
    the easiest way around it is to create multiple versions of
    `rails.conf`, one per environment, and then use the appropriate one
    in your `script/nginx` file.
-   You can’t specify a custom port either. Patches welcome.
-   You won’t see the log output. Either `tail log/development.log` when
    necessary, or suggest a patch for script/nginx. I’d prefer
    the latter.

Beyond that, it should work smoothly. If I’m wrong, that’s what the
comments form is for.

Also, you can find all of my config files, as well as other details of
how I’ve set up my machine since installing Snow Leopard, on
[gist.github.com](http://gist.github.com/181369).

------------------------------------------------------------------------

<div class="comments">
<div class="comment-author">
<a href="http://andascarygoat.com">Andrei Bocan</a> left a comment on 27
Sep, 2009:</div>

<div class="comment" markdown="1">
Wouldn’t it have been easier to just use passenger-install-nginx-module
?

That installs pcre and nginx with the module baked in, and it prompts
you for the install path.

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 27 Sep,
2009:</div>

<div class="comment" markdown="1">
**Andrei**: I could have done that, sure. I’m comfortable enough setting
configure options, though. Either I’d be setting them through the
advanced settings part of that tool, or by hand. Not too much
difference.

</div>
<div class="comment-author">
<a href="http://www.givereal.com">Patrick</a> left a comment on 28 Sep,
2009:</div>

<div class="comment" markdown="1">
If you add `tail -f log/development.log &` before the nginx command in
script/nginx you will be able to see the log output inline.

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 28 Sep,
2009:</div>

<div class="comment" markdown="1">
Ah, that’s a neat suggestion Patrick. Only flaw I’ve found with it thus
far is that the tail process doesn’t get killed with the nginx process,
so if you run it twice, then you’ll see each line duplicated.

Still, a step in the right direction.

</div>
<div class="comment-author">
<a href="http://www.givereal.com">Patrick</a> left a comment on 29 Sep,
2009:</div>

<div class="comment" markdown="1">
If you give `tail` the `--pid=$$` argument it will die with the script.

</div>
<div class="comment-author">
Cory left a comment on 5 Nov, 2009:</div>

<div class="comment" markdown="1">
Do you find advantages to this method versus installing nginx the usual
way, and configuring a vhost for each of your projects?

That way, with an entry in your /etc/hosts file you can just ‘touch
tmp/restart.txt’ and visit http://name\_of\_your\_project.local (or some
similar thing…)

Additionally, you can configure separate vhosts for different rails
environments, and make the /etc/hosts entry something like
dev.projectname.local or prod.projectname.local - pretty handy.

I find it more convenient not to have to do ‘script/server’ all the
time, and ‘tail -f log/development.log’ works like normal.

</div>
<div class="comment-author">
<a href="http://freelancing-gods.com">pat</a> left a comment on 5 Nov,
2009:</div>

<div class="comment" markdown="1">
Hi Cory

The main difference is I like being able to control the Rails app all
from one place - the Rails app itself. So this setup means I can easily
build a test application and fire Nginx up to test it, without needing
to worry about sudo access or config files.

Beyond that, either approach is pretty much the same.

</div>
<div class="comment-author">
<a href="http://stephencelis.com">stephencelis</a> left a comment on 17
Nov, 2009:</div>

<div class="comment" markdown="1">
You’ve inspired me to create a little wrapper script:

http://gist.github.com/236635

By default it proxies to a Mongrel, but it’s a one-line config change to
Unicorn, and works with Passenger easily enough—see your config, above
;). A bit more work and it could be switchable between all of them, out
of the box.

</div>
<div class="comment-author">
<a href="http://expectedbehavior.com">joel meador</a> left a comment on
15 Jan, 2010:</div>

<div class="comment" markdown="1">
I really liked what you did here. I wanted to use it with Unicorn, so I
made that work. Details linked from this tweet.  
http://twitter.com/joelmeador/status/7643490205

</div>
<div class="comment-author">
<a href="http://www.hostedstatuspage.com">Daniel @ Status Page</a> left
a comment on 20 Feb, 2015:</div>

<div class="comment" markdown="1">
Thanks for writing this, its just saved me a ton of time tweaking
invidiual configuration settings.

</div>
</div>

