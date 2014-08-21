# Capistrano3 Rainbows

> Note: This fork makes some minimal changes to make this awesome gem work with Rainbows. License and authors were maintained.

> The README file was altered to match the renamed capistrano tasks.

This is a capistrano v3 plugin that integrates Rainbows tasks into capistrano deployment scripts; it was heavily inspired by [sosedoff/capistrano-unicorn](https://github.com/sosedoff/capistrano-unicorn) but written from scratch to use the capistrano 3 syntax.

### Gotchas

- The `rainbows:start` task invokes Rainbows as `bundle exec rainbows`.

- When running tasks not during a full deployment, you may need to run the `rvm:hook`:

    `cap production rvm:hook rainbows:start`

### Conventions

You can override the defaults by `set :rainbows_example, value` in the `config/deploy.rb` or `config/deploy/ENVIRONMENT.rb` capistrano deployment files.

Example Unicorn config [examples/unicorn.rb](https://github.com/tablexi/capistrano3-unicorn/blob/master/examples/unicorn.rb)

- `:rainbows_pid`

    Default assumes your pid file will be located in `CURRENT_PATH/tmp/pids/rainbows.pid`. The rainbows_pid should be defined with an absolute path.

- `:rainbows_config_path`

    Default assumes that your rainbows configuration will be located in `CURRENT_PATH/config/rainbows/RAILS_ENV.rb`

- `:rainbows_roles`

    Roles to run rainbows commands on. Defaults to :app

- `:rainbows_options`

    Set any additional options to be passed to rainbows on startup. Defaults to none

- `:rainbows_rack_env`

    Set the RACK_ENV. Defaults to deployment unless the RAILS_ENV is development. Valid options are "development", "deployment", or "none". See the [RACK ENVIRONMENT](http://rainbows.bogomips.org/rainbows_1.html) section of the rainbows documentation for more information.

- `:rainbows_bundle_gemfile`

    ***REMOVED in v0.2.0***

    Set the BUNDLE_GEMFILE in a before_exec block in your unicorn.rb. See [sandbox](http://unicorn.bogomips.org/Sandbox.html) and [unicorn-restart-issue-with-capistrano](https://stackoverflow.com/questions/8330577/unicorn-restart-issue-with-capistrano)

- `:unicorn_restart_sleep_time`

    In `rainbows:legacy_restart` send the USR2 signal, sleep for this many seconds (defaults to 3), then send the QUIT signal

### Setup

Add the library to your `Gemfile`:

```ruby
group :development do
  gem 'capistrano3-rainbows'
end
```

Add the library to your `Capfile`:

```ruby
require 'capistrano3/unicorn'
```

Invoke Rainbows from your `config/deploy.rb` or `config/deploy/ENVIRONMENT.rb`:

If `preload_app:true` use:

```ruby
after 'deploy:publishing', 'deploy:restart'
namespace :deploy do
  task :restart do
    invoke 'rainbows:restart'
  end
end
```

If `preload_app:true` and you need capistrano to cleanup your oldbin pid use:

```ruby
after 'deploy:publishing', 'deploy:restart'
namespace :deploy do
  task :restart do
    invoke 'rainbows:legacy_restart'
  end
end
```

Otherwise use:

```ruby
after 'deploy:publishing', 'deploy:restart'
namespace :deploy do
  task :restart do
    invoke 'rainbows:reload'
  end
end
```

Note that presently you must put the `invoke` outside any `on` block since the task handles this for you; otherwise you will get an `undefined method 'verbosity'` error.
