2.0.2
-------
- Don't consider global shutdown bool when exhausting the queue during
  shutdown. This led to `shutdown_timeout` not being respected when
  processing remaining jobs left in the queue with a high `shutdown_timeout`.

2.0.1
-------
- Remove scripts from `bin/`

2.0.0
-------

- Refactor internals to use `concurrent-ruby`
- Yield more exception details to handler. The new syntax allows you to setup a
    global exception with the following syntax:

    ```ruby
    # ex    => The caught exception object
    # klass => The job class
    # args  => An array of the args passed to the job

    SuckerPunch.exception_handler = -> (ex, klass, args) { ExceptionNotifier.notify_exception(ex) }
    ```

- Invoke asynchronous job via `perform_async` and `perform_in` class method (*backwards
    incompatible change*):

    ```ruby
    LogJob.perform_async("login")
    LogJob.perform_in(60, "login") # `perform` will be executed 60 sec. later
    ```

- Drop support for Ruby `< 2.0`
- Allow shutdown timeout to be set (default is 8 sec.):

    ```ruby
    SuckerPunch.shutdown_timeout = 15 # time in seconds
    ```

1.6.0
--------

- Update to use Celluloid `0.17.2`
- Removed the `SuckerPunch.clear_queues` method


1.5.1
--------

- Lock to Celluloid `0.16.0` due to `0.16.1` being [yanked](https://rubygems.org/gems/celluloid/versions)

1.5.0
--------

- Allow number of workers to be up to and including 200
- Don't clear out non-Sucker Punch Celluloid registry on boot [#113](https://github.com/brandonhilkert/sucker_punch/pull/113)

1.4.0
--------

- Added Rails generate task to create a job from the command line

1.3.2
--------

- Remove extraneous conditions in core extension `underscore`

1.3.1
--------

- Require `sucker_punch` before inline testing library to ensure changes stick

1.3
--------

- Update to use Celluloid `0.16`

1.2.1
--------

- Go back to Celluloid `0.15.2` since it's not production ready

1.2
--------

- Update to use Celluloid `0.16`

1.1
--------

- Delegate to Celluloid's exception handler

1.0.5
--------

- Move `to_prepare` callback in Railtie out of initializer

1.0.4
--------

- Fix superclass for `testing/inline` module

1.0.3
--------

- Track instantiated queues through Celluloid registry
- Clear Celluloid registry on every Rails request in Development

1.0.2
--------

- Update Celluloid dependency to 0.15.1

1.0.1
--------

- Fix how workers are defined on the Job so that jobs can be safely subclassed

1.0.0.beta3
--------

- Constrain workers when creating a queue to raise more helpful exceptions

1.0.0.beta2
--------

- Add `workers` method to job to specify number of Celluloid pool workers

1.0.0.beta
--------

- Removed the need for a configuration initializer
- include `SuckerPunch::Job` instead of `SuckerPunch::Worker`
- Use standard Ruby job class instantiation to perform a job (ie. LogJob.new.async.perform)

0.5.1
--------

- Add `SuckerPunch.logger`
- Add `SuckerPunch.logger=`
- Set SuckerPunch logger to Rails.logger within a Rails application

0.5
--------

- `SuckerPunch::Queue#size` now returns the number of messages enqueued
- `SuckerPunch::Queue#workers` now returns the number of workers in the queue
- Update Celluloid dependency

0.4.1
--------

- Remove `size` option when defining a queue, prefer `workers`
- Update Celluloid dependency

0.4
-----------
- Prefer `workers` stat method over `size`
- Update config to use `workers` instead of `size`

old config:

```Ruby
# config/initializers/sucker_punch.rb

SuckerPunch.config do
  queue name: :log_queue, worker: LogWorker, size: 10
end
```

new config:

```Ruby
# config/initializers/sucker_punch.rb

SuckerPunch.config do
  queue name: :log_queue, worker: LogWorker, workers: 10
end
```
- Add testing library to stub out workers (see testing section in README)

0.3.1
-----------

- Fix location of inline testing library

`spec/spec_helper.rb`
```ruby
require 'sucker_punch/testing/inline'
SuckerPunch::Queue[:log_queue].async.perform("login") # => SYNCHRONOUS
```

0.3
-----------

- Now includes a testing library that will run all jobs synchronously.

`spec/spec_helper.rb`
```ruby
require 'sucker_punch/testing'
SuckerPunch::Queue[:log_queue].async.perform("login") # => SYNCHRONOUS
```
