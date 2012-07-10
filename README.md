These are very workers that test performance of [Iron.io](http://www.iron.io) services. This will
give you an accurate representation of performance since it's all within AWS.

# Running these examples.

* Create an iron.json file in this directory with your project_id (and token if you haven't set
that in your environment or global .iron.json file). See [Configuration](http://dev.iron.io/articles/configuration/) for
information on setting up your credentials.

## Run IronWorker example:

* Upload the worker:

    iron_worker upload cache_worker

* Queue up a bunch of tasks:

    ruby queue_cache_worker.rb

Login to the Iron.io HUD at http://hud.iron.io to the running tasks.
