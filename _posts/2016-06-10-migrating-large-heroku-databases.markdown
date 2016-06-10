---
title: "Migrating Large Heroku Databases"
categories:
  - heroku
  - postgresql
  - database
---

Recently I had to migrate a large (120GB) PostgreSQL database on Heroku from v9.1 to v9.5 for [Flying Sphinx](http://flying-sphinx.com). I got some excellent suggestions from [Keiko Oda](https://twitter.com/keiko713) of Heroku on how to approach this, and then rehearsed the full process a few times to be sure about how it would proceed. I figure it's worth documenting in case it's useful for others (or even myself the next time around).

I'll cover each point in a little more detail, but the general approach was:

1. Create a high-performance follower for my production database.
2. Fire up an EC2 instance with a large hard-drive.
3. Once the follower is caught up and the EC2 instance is ready, put the app into maintenance mode and scale down to no workers.
4. Use `pg_backup` on EC2 to copy the follower database, using as many CPU cores as possible.
5. Create a new high-performance primary database.
6. Restore the EC2 backup onto the new primary database, again using as many CPU cores as possible.
7. Create a new follower database at your actual level, following the high-performance primary database.
8. Disable maintenance mode and scale workers back to normal.
9. Once the follower has caught up, quickly jump back to maintenance mode and disable workers, promote that follower to be the new primary database, and then turn off maintenance mode and return workers to normal.
10. Delete both the original high-performance follower and the high-performance former-primary databases.
11. Add a new follower at your preferred level.
12. Turn that expensive EC2 instance off.

And two caveats: a lot of these services can be expensive, so please do some research into the costs of [EC2 instances](http://aws.amazon.com/ec2/pricing/) and [Heroku PostgreSQL databases](https://www.heroku.com/pricing#databases). Also, the following commands worked for me, but that was after many hours of testing and rehearsals. I highly recommend you do a run-through on a non-critical system first. You shouldn't entrust the safety of your production databases to some instructions you found on a blog somewhere!

### 1. High-Performance Follower

The database I've been using for Flying Sphinx is a Standard-0 instance, and that serves my purposes fine. However, the goal is to have the switch-over taking as little time as possible, hence we want to use higher-performance databases as part of the process. In this case, I opted for Standard-5.

    # Where WHITE is my original 9.1 database:
    heroku addons:create heroku-postgresql:standard-5 --follow HEROKU_POSTGRESQL_WHITE_URL

Because my original database is v9.1, the follower is v9.1 as well.

### 2. Using EC2 for the backing up and restore.

Again, it's all about speed - but also, we need plenty of disk space for the backup files - so I booted up an `i2.4xlarge` instance through OpsWorks. I'm sure it's possible to set it up yourself through EC2 directly, but OpsWorks is what I'm familiar with, so that was the path I took.

It's worth noting that while that EC2 instance did have some large hard-drives available, they weren't formatted or mounted by default. With some help from [Colby Swandale](https://twitter.com/0xColby) and [Nigel Sheridan-Smith](https://twitter.com/GreenShoresAU), I got that sorted - here are the commands I ran within that instance:

    # SSH'd into the EC2 instance
    sudo fdisk /dev/xvdb
    > n # new partition, accept all default settings
    > w # write partition to the system
    sudo mkfs.ext4 /dev/xvdb # format the partition
    sudo mkdir -p /mnt/space # create the mount point
    sudo mount -t ext4 /dev/xvdb /mnt/space # mount the partition

Then, install the required PostgreSQL tools:

    sudo apt-get install postgresql-client-common
    sudo apt-get install postgresql-client-9.3

And get a directory setup for the default user (in my case, `ubuntu`) where we can store the database backup:

    cd /mnt/space
    sudo mkdir backups
    sudo chown ubuntu:ubuntu ./backups
    cd backups

### 3. Into Maintenance

Before we proceed, make sure your new follower has caught up:

    heroku pg:info

In my case, I have just 3 web and 1 worker processes. You should take note of your own process counts!

And then into maintenance mode we go. This means your app will not be accessible to anyone, so hopefully you've given your customers advance warning of this outage!

    heroku maintenance:on
    heroku ps:scale worker=0

Again, wait until the follower is up-to-date with your primary database (you're looking for `Behind By: 0 commits` in the `pg:info` output), and then you're good to proceed - the goal here is to ensure both the primary and follower databases aren't being modified while you back everything up.

### 4. Back up the database

I ran the backup command within `screen`, to ensure it would run smoothly even if I lost internet access at some point. Also, you'll notice I'm using 16 CPU cores here - that's what the EC2 instance has available (and it's well under the maximum allowed database connections too).

    screen
    echo `date`; pg_dump -f heroku -F directory -j 16 --no-synchronized-snapshots HIGH_PERF_FOLLOWER_URL; echo `date`

I've echo'd the current time both at the beginning and the end of each process, to help me time the overall backup time required exactly. In my case, this took a bit over half-an-hour (but was around the two-hour mark without all the high-performance pieces).

For those not familiar with screen: to exit the screen process (while leaving it running) type control-A then control-D. To return to that screen process, use `screen -r`.

### 5. High-Performance Primary

This database will function as our temporary new database at the latest version (currently v9.5) - again, taking advantage of the higher performance to make the entire process as quick as possible.

    heroku addons:create heroku-postgresql:standard-5

### 6. Restore the database.

Once the new database is ready, let's load our backup into it - again, using 16 cores. Again, run this within a `screen` - and perhaps copy and paste the initial time output somewhere, because when you return to that screen, it may have scrolled out of view.

    echo `date`; pg_restore -F directory -j 16 -d HIGH_PERF_PRIMARY_URL heroku; echo `date`

This was the slowest part of the whole process for me, taking about 100 minutes.

### 7. Create your preferred database as a follower

Let's promote that new high-performance database to be the primary database for our app, and then add a new follower at the plan we're normally expecting.

    # In my case it was called PUCE.
    heroku pg:promote HEROKU_POSTGRESQL_PUCE
    # Standard-0 is fine for me:
    heroku addons:create heroku-postgresql:standard-0 --follow HEROKU_POSTGRESQL_PUCE_URL

### 8. Out of Maintenance

Turn your app back on and scale workers back to normal levels:

    heroku ps:scale worker=1
    heroku maintenance:off

### 9. Promote the preferred database

It may take some time for your new follower to catch up - and that's fine, because your site will be functional in the meantime anyway, using the (temporary) high-performance primary database. But once that follower's ready, you can promote it to be the new primary database. Again, you'll want to duck into maintenance mode to avoid data changes!

    heroku maintenance:on
    heroku ps:scale worker=0
    heroku pg:info
    # Wait for your follower to be caught up
    # Then change it so it's no longer a follower:
    heroku pg:unfollow HEROKU_POSTGRESQL_BROWN_URL
    # And promote it to primary:
    heroku pg:promote HEROKU_POSTGRESQL_BROWN
    heroku ps:scale worker=1
    heroku maintenance:off

### 10. Delete high-performance databases

You should now be on your preferred database plan and version. If you're happy with everything, it's time to delete those high-performance databases (I did this through [Heroku's Dashboard](http://dashboard.heroku.com)).

### 11. Add a new follower

I like to have a follower always present in case of emergencies - certainly for critical infrastructure like Flying Sphinx! - so I added a new follower:

    heroku addons:create heroku-postgresql:standard-0 --follow HEROKU_POSTGRESQL_BROWN_URL

### 12. Shutting down the EC2 instance

Everything's done and your site's purring along on the latest PostgreSQL infrastructure. It should now be safe to turn off that EC2 instance, and hopefully then celebrate the completion of a successful database migration!
