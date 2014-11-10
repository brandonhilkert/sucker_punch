# Sucker Punch

[![Build Status](https://travis-ci.org/brandonhilkert/sucker_punch.png?branch=master)](https://travis-ci.org/brandonhilkert/sucker_punch)
[![Code Climate](https://codeclimate.com/github/brandonhilkert/sucker_punch.png)](https://codeclimate.com/github/brandonhilkert/sucker_punch)

Sucker Punch is a single-process Ruby asynchronous processing library. It's [girl_friday](https://github.com/mperham/girl_friday)  and DSL sugar on top of [Celluloid](https://github.com/celluloid/celluloid/). With Celluloid's actor pattern, we can do asynchronous processing within a single process. This reduces costs of hosting on a service like Heroku along with the memory footprint of having to maintain additional jobs if hosting on a dedicated server. All queues can run within a single Rails/Sinatra process.

Sucker Punch is perfect for asynchronous processes like emailing, data crunching, or social platform manipulation. No reason to hold up a user when you can do these things in the background within the same process as your web application...

## Installation

Add this line to your application's Gemfile:

    gem 'sucker_punch', '~> 1.0'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sucker_punch

## Usage

Each job acts as its own queue and should be a separate Ruby class that:

* includes `SuckerPunch::Job`
* defines the instance method `perform` that includes the code the job will run when enqueued


```Ruby
# app/jobs/log_job.rb

class LogJob
  include SuckerPunch::Job

  def perform(event)
    Log.new(event).track
  end
end
```

Synchronous:

```Ruby
LogJob.new.perform("login")
```

Asynchronous:

```Ruby
LogJob.new.async.perform("login") # => nil
```

Jobs interacting with `ActiveRecord` should take special precaution not to exhaust connections in the pool. This can be done with `ActiveRecord::Base.connection_pool.with_connection`, which ensures the connection is returned back to the pool when completed.

```Ruby
# app/jobs/awesome_job.rb

class AwesomeJob
  include SuckerPunch::Job

  def perform(user_id)
    ActiveRecord::Base.connection_pool.with_connection do
      user = User.find(user_id)
      user.update_attributes(is_awesome: true)
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
      LogJob.new.async.perform("User #{user.id} became awesome!")
    end
  end
end
```

The number of workers can be set from the Job using the `workers` method:

```Ruby
class LogJob
  include SuckerPunch::Job
  workers 4

  def perform(event)
    Log.new(event).track
  end
end
```

If the `workers` method is not set, the default is `2`.

## Perform In

Many background processing libraries have methods to perform operations after a
certain amount of time. Fortunately, timers are built-in to Celluloid, so you
can take advantage of them with the `later` method:

``` ruby
class Job
  include SuckerPunch::Job

  def perform(data)
    puts data
  end

  def later(sec, data)
    after(sec) { perform(data) }
  end
end

Job.new.async.perform("asdf")
Job.new.async.later(60, "asdf") # `perform` will be excuted 60 sec. later
```

## Logger

```Ruby
SuckerPunch.logger = Logger.new('sucker_punch.log')
SuckerPunch.logger # => #<Logger:0x007fa1f28b83f0>
```

_Note: If Sucker Punch is being used within a Rails application, Sucker Punch's logger
is set to Rails.logger by default._

## Testing

Requiring this library causes your jobs to run everything inline. So a call to the following will actually be SYNCHRONOUS:

```Ruby
# spec/spec_helper.rb
require 'sucker_punch/testing/inline'
```

```Ruby
Log.new.async.perform("login") # => Will be synchronous and block until job is finished
```

## Active Job

Sucker Punch has been added as an Active job adapter in the upcoming Rails 4.2 release.
See the [guide](http://edgeguides.rubyonrails.org/active_job_basics.html) for
configuration and implementation.

Add Sucker Punch to your `Gemfile`:

```Ruby
gem 'sucker_punch'
```

And then configure the backend to use Sucker Punch:

```Ruby
Rails.application.config.active_job.queue_adapter = :sucker_punch
```

## Troubleshooting

### Initializers for forking servers (Unicorn, Passenger, etc.)

Previously, Sucker Punch required an initializer and that posed problems for
Unicorn and Passenger and other servers that fork.  Version 1 was rewritten to
not require any special code to be executed after forking occurs. Please remove
 if you're using version `>= 1.0.0`

### Class naming

Job classes are ultimately Celluloid Actor classes. As a result, class names
are susceptible to being clobbered by Celluloid's internal classes.  To ensure
the intended application class is loaded, preface classes with `::`, or use
names like `NotificationsMailer` or `UserMailer`. Example:

```Ruby
class EmailJob
  include SuckerPunch::Job

  def perform(contact)
    @contact = contact
    ::Notifications.contact_form(@contact).deliver # => If you don't use :: in this case, the notifications class from Celluloid will be loaded
  end
end
```

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

## Gem Name

...is awesome. But I can't take credit for it. Thanks to
[@jmazzi](https://twitter.com/jmazzi) for his superior naming skills. If you're
looking for a name for something, he is the one to go to.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
