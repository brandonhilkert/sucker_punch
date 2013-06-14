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
