# Sucker Punch

[![Build Status](https://travis-ci.org/brandonhilkert/sucker_punch.png?branch=master)](https://travis-ci.org/brandonhilkert/sucker_punch)
[![Code Climate](https://codeclimate.com/github/brandonhilkert/sucker_punch.png)](https://codeclimate.com/github/brandonhilkert/sucker_punch)

Sucker Punch is a single-process Ruby asynchronous processing library.
This reduces costs
of hosting on a service like Heroku along with the memory footprint of
having to maintain additional jobs if hosting on a dedicated server.
All queues can run within a single application (eg. Rails, Sinatra, etc.) process.

Sucker Punch is perfect for asynchronous processes like emailing, data
crunching, or social platform manipulation. No reason to hold up a
user when you can do these things in the background within the same
process as your web application...

Sucker Punch is built on top of [concurrent-ruby]
(https://github.com/ruby-concurrency/concurrent-ruby). Each job is setup as
a pool, which equates to its own queue with individual workers working against
the jobs. Unlike most other background processing libraries, Sucker
Punch's jobs are stored in memory. The benefit to this is there is no
additional infrastructure requirement (ie. database, redis, etc.). However,
if the web processes are restarted with jobs remaining in the queue,
they will be lost. For this reason, Sucker Punch is generally
recommended for jobs that are fast and non-mission critical (ie. logs, emails,
etc.).

## Installation

Add this line to your application's Gemfile:

    gem 'sucker_punch', '~> 2.0'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sucker_punch

## Backwards Compatibility

In version `~> 2.0.0`, the syntax to enqueue an asynchronous background job has changed from:

```ruby
LogJob.new.async.perform(...)
```

to:


```ruby
LogJob.perform_async(...)
```

If you're upgrading from a pre-`2.0.0` release and want to retain the old
syntax `LogJob.new.async.perform(...)`, you can include
`sucker_punch/async_syntax` in your application.

For Rails, you could add an initializer:

```ruby
# config/initializers/sucker_punch.rb

require 'sucker_punch/async_syntax'
```

## Usage

Each job acts as its own queue and should be a separate Ruby class that:

* includes `SuckerPunch::Job`
* defines the `perform` instance method that includes the code the job will run when enqueued


```Ruby
# app/jobs/log_job.rb

class LogJob
  include SuckerPunch::Job

  def perform(event)
    Log.new(event).track
  end
end
```

#### Synchronous

```Ruby
LogJob.new.perform("login")
```

#### Asynchronous

```Ruby
LogJob.perform_async("login")
```

#### Configure the # of the Workers

The default number of workers (threads) running against your job is `2`. If
you'd like to configure this manually, the number of workers can be
set on the job using the `workers` class method:

```Ruby
class LogJob
  include SuckerPunch::Job
  workers 4

  def perform(event)
    Log.new(event).track
  end
end
```

#### Executing Jobs in the Future

Many background processing libraries have methods to perform operations after a
certain amount of time and Sucker Punch is no different. Use the `perform_in`
with an argument of the number of seconds in the future you would like the job
to job to run.

``` ruby
class DataJob
  include SuckerPunch::Job

  def perform(data)
    puts data
  end
end

DataJob.perform_async("asdf") # immediately perform asynchronously
DataJob.perform_in(60, "asdf") # `perform` will be excuted 60 sec. later
```

#### `ActiveRecord` Connection Pool Connections

Jobs interacting with `ActiveRecord` should take special precaution not to
exhaust connections in the pool. This can be done
with `ActiveRecord::Base.connection_pool.with_connection`, which ensures
the connection is returned back to the pool when completed.

```Ruby
# app/jobs/awesome_job.rb

class AwesomeJob
  include SuckerPunch::Job

  def perform(user_id)
    ActiveRecord::Base.connection_pool.with_connection do
      user = User.find(user_id)
      user.update(is_awesome: true)
    end
  end
end
```

We can create a job from within another job:

```Ruby
class AwesomeJob
  include SuckerPunch::Job

  def perform(user_id)
    ActiveRecord::Base.connection_pool.with_connection do
      user = User.find(user_id)
      user.update_attributes(is_awesome: true)
      LogJob.perform_async("User #{user.id} became awesome!")
    end
  end
end
```

#### Logger

```Ruby
SuckerPunch.logger = Logger.new('sucker_punch.log')
SuckerPunch.logger # => #<Logger:0x007fa1f28b83f0>
```

_Note: If Sucker Punch is being used within a Rails application, Sucker Punch's logger
is set to Rails.logger by default._

#### Exceptions

You can customize how to handle uncaught exceptions that are raised by your jobs.

For example, using Rails and the ExceptionNotification gem,
add a new initializer `config/initializers/sucker_punch.rb`:

```Ruby
# ex    => The caught exception object
# klass => The job class
# args  => An array of the args passed to the job

SuckerPunch.exception_handler = -> (ex, klass, args) { ExceptionNotifier.notify_exception(ex) }
```

Or, using Airbrake:

```Ruby
SuckerPunch.exception_handler = -> (ex, klass, args) { Airbrake.notify(ex) }
```

#### Shutdown Timeout

Sucker Punch goes through a series of checks to attempt to shut down the queues
and their threads. A "shutdown" command is issued to the queues, which gives
them notice but allows them to attempt to finish all remaining jobs.
Subsequently enqueued jobs are discarded at this time.

The default `shutdown_timeout` (the # of seconds to wait before forcefully
killing the threads) is 8 sec. This is to allow applications hosted on Heroku
to attempt to shutdown prior to the 10 sec. they give an application to
shutdown with some buffer.

To configure something other than the default 8 sec.:

```ruby
  SuckerPunch.shutdown_timeout = 15 # # of sec. to wait before killing threads
```

#### Timeouts

Using `Timeout` causes persistent connections to
[randomly get corrupted](http://www.mikeperham.com/2015/05/08/timeout-rubys-most-dangerous-api).
Do not use timeouts as control flow, use built-in connection timeouts.
If you decide to use Timeout, only use it as last resort to know something went very wrong and
ideally restart the worker process after every timeout.

## Testing

Requiring this library causes your jobs to run everything inline.
So a call to the following will actually be SYNCHRONOUS:

```Ruby
# spec/spec_helper.rb
require 'sucker_punch/testing/inline'
```

```Ruby
LogJob.perform_async("login") # => Will be synchronous and block until job is finished
```

## Rails

If you're using Sucker Punch with Rails, there's a built-in generator task:

```ruby
$ rails g sucker_punch:job logger
```

would create the file `app/jobs/logger_job.rb` with a unimplemented `#perform`
method.

## Active Job

Sucker Punch has been added as an Active Job adapter in Rails 4.2.
See the [guide](http://edgeguides.rubyonrails.org/active_job_basics.html) for
configuration and implementation.

Add Sucker Punch to your `Gemfile`:

```Ruby
gem 'sucker_punch'
```

And then configure the backend to use Sucker Punch:

```Ruby
# config/initializers/sucker_punch.rb
Rails.application.configure do
  config.active_job.queue_adapter = :sucker_punch
end

```

If you want to use Sucker Punch version `2.0.0+` with Rails `< 5.0.0`, be sure
to include the backwards compatibility module in an initializer:


```ruby
# config/initializers/sucker_punch.rb

require 'sucker_punch/async_syntax'
```

## Troubleshooting

### Initializers for forking servers (Unicorn, Passenger, etc.)

Previously, Sucker Punch required an initializer and that posed problems for
servers that fork (ie. Unicorn and Passenger). Version 1 was rewritten to
not require any special code to be executed after forking occurs. Please remove
 if you're using version `>= 1.0.0`

### Cleaning test data transactions

If you're running tests in transactions (using Database Cleaner or a native solution), Sucker Punch jobs may have trouble finding database records that were created during test setup because the job class is running in a separate thread and the Transaction operates on a different thread so it clears out the data before the job can do its business. The best thing to do is cleanup data created for tests jobs through a truncation strategy by tagging the rspec tests as jobs and then specifying the strategy in `spec_helper` like below. And do not forget to turn off transactional fixtures (delete, comment or set it to `false`).

```Ruby
# spec/spec_helper.rb
RSpec.configure do |config|

  # Turn off transactional fixtures (delete, comment or set it to `false`)
  # config.use_transactional_fixtures = true

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  # Clean up all jobs specs with truncation
  config.before(:each, job: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

# spec/jobs/email_job_spec.rb
require 'spec_helper'

# Tag the spec as a job spec so data is persisted long enough for the test
describe EmailJob, job: true do
  describe "#perform" do
    let(:user) { FactoryGirl.create(:user) }

    it "delivers an email" do
      expect {
        EmailJob.new.perform(user.id)
      }.to change{ ActionMailer::Base.deliveries.size }.by(1)
    end
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
