# RTP

A plugin for [Remember The Milk](https://www.rememberthemilk.com) ready to deploy to [Heroku](www.heroku.com) that will automatically postpone or complete tasks, using the [Milkman](https://github.com/kevintuhumury/milkman) and [Rufus](https://github.com/jmettraux/rufus-scheduler) gems.

## Usage
### Fork this repository
You can do this automatically through Github, or download it.
### Create an app using Heroku in the directory

    $ heroku create

### Get API Keys
You will need the API information from Remember The Milk. Milkman has instructions on how to obtain this information. Once you have the api key, shared secret, and auth token, set them in Heroku. The brackets are to signify the portions to replace.

    $ heroku config:set API_KEY=[YOURAPIKEY]
    $ heroku config:set SHARED_SECRET=[YOURSHAREDSECRET]
    $ heroku config:set AUTH_TOKEN=[YOURAUTHTOKEN]
    
### Set Frequency
Set the frequency you want the tasks to run. Remember The Milk recommends not calling anything more than once per second to prevent yourself from being blocked. 30 minutes should probably be acceptable.

    $ heroku config:set FREQUENCY=30m

### Push to Heroku

    $ git push heroku master

### Scale your dyno

    $ heroku ps:scale clock=1

## Contributing to RTP

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.

## Licensing

* Copyright 2014 Richard Lynskey. Released under the MIT License.
* This product uses the [Remember The Milk](https://www.rememberthemilk.com) API but is not endorsed or certified by [Remember The Milk](https://www.rememberthemilk.com).