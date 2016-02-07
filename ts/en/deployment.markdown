---
layout: ts_en
title: Deployment
---


Deployment
----------

Once we’ve [installed Sphinx](installing_sphinx.html) and [installed
ThinkingSphinx](installing_thinking_sphinx.html) on your production
server, as well as setting up all of our indexes, we can deploy it to
our production servers.

### Basics

Essentially, the following steps need to be performed for a deployment:

-   stop Sphinx `searchd` (ensure it’s running)
-   generate Sphinx configuration
-   start Sphinx `searchd`
-   ensure index is regularly rebuilt

Configuring Sphinx for our production environment includes setting where
the PID file and the index files are stored. In your `config/sphinx.yml`
file, set up the following additional parameters:

{%highlight yaml%}  
production:  
 pid\_file: /path/to/app/shared/tmp/searchd.pid  
 searchd\_file\_path: /path/to/app/shared/db/sphinx  
{%endhighlight%}

You’ll want to make sure that the application shared folder has `db` and
`tmp` subdirectories. You’ll also want to double check the permissions
of these folders so that the user the application and searchd both runs
as can write to both folders.

Before deploying, we generally assume that the Sphinx `searchd` search
daemon is running. You may need to manually configure and run the daemon
the first deployment with ThinkingSphinx support added.

### Deploying With Capistrano

Deploying via Capistrano is simplified by the included recipe file that
comes with the ThinkingSphinx plugin.

The first step is to include the recipe in order to define the necessary
tasks for us:

{%highlight ruby%}

1.  If you’re using Thinking Sphinx as a gem (Rails 3 way):  
    require ‘thinking\_sphinx/deploy/capistrano’
2.  If you’re using Thinking Sphinx as a plugin:  
    require ‘vendor/plugins/thinking-sphinx/recipes/thinking\_sphinx’  
    {%endhighlight%}

Now we can define our callbacks at the and of `deploy.rb` in order to
make sure that Sphinx is properly configured, indexed, and started on
each deploy:

{%highlight ruby%}  
before ‘deploy:update\_code’, ‘thinking\_sphinx:stop’  
after ‘deploy:update\_code’, ‘thinking\_sphinx:start’

namespace :sphinx do  
 desc “Symlink Sphinx indexes”  
 task :symlink\_indexes, :roles =&gt; \[:app\] do  
 run “ln -nfs \#{shared\_path}/db/sphinx \#{release\_path}/db/sphinx”  
 end  
end

after ‘deploy:finalize\_update’, ‘sphinx:symlink\_indexes’  
{%endhighlight%}

The above makes sure we stop the Sphinx `searchd` search daemon before
we update the code. After the code is updated, we reconfigure Sphinx and
then restart. We’ll setup a `cron` job next to keep the indexes
up-to-date.

### Regularly Rebuilding the Index

One of the side effects of the Sphinx indexing methodology is that it is
necessary to constantly rebuild the index in order to be able to search
with recent changes. In order to do this, we set up a `cron` job to run
the appropriate command.

In your `/etc/crontab` file, add the following line to the bottom:

{%highlight bash%}  
0 \* \* \* \* deploy cd /path/to/app/current && /usr/local/bin/rake
thinking\_sphinx:index RAILS\_ENV=production  
{%endhighlight%}

Also, you can use the [whenever](https://github.com/javan/whenever) gem
to control your Cron tasks from the Rails app. The same job for
`whenever` in `config/schedule.rb` looks like this:

{%highlight ruby%}  
every 2.minutes do  
 rake “thinking\_sphinx:index”  
end  
{%endhighlight%}
