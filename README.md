# Sucker Punch

[![Build Status](https://travis-ci.org/brandonhilkert/sucker_punch.png?branch=master)](https://travis-ci.org/brandonhilkert/sucker_punch)
[![Code Climate](https://codeclimate.com/github/brandonhilkert/sucker_punch.png)](https://codeclimate.com/github/brandonhilkert/sucker_punch)

Sucker Punch is a single-process Ruby asynchronous processing library. It's [girl_friday](https://github.com/mperham/girl_friday) with syntax from [Sidekiq](https://github.com/mperham/sidekiq) and DSL sugar on top of [Celluloid](https://github.com/celluloid/celluloid/). With Celluloid's actor pattern, we can do asynchronous processing within a single process. This reduces costs of hosting on a service like Heroku along with the memory footprint of having to maintain additional workers if hosting on a dedicated server. All queues can run within a single Rails/Sinatra process.

Sucker Punch is perfect for asynchronous processes like emailing, data crunching, or social platform manipulation. No reason to hold up a user when you can do these things in the background within the same process as your web application...

## Installation

Add this line to your application's Gemfile:

    gem 'sucker_punch'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sucker_punch

## Configuration


```Ruby
# config/initializers/sucker_punch.rb

SuckerPunch.config do
  queue name: :log_queue, worker: LogWorker, workers: 10
  queue name: :awesome_queue, worker: AwesomeWorker, workers: 2
end
```

## Usage

```Ruby
# app/workers/log_worker.rb

class LogWorker
  include SuckerPunch::Worker

  def perform(event)
    Log.new(event).track
  end
end
```

All workers should define an instance method `perform`, of which the job being queued will adhere to.

Workers interacting with `ActiveRecord` should take special precaution not to exhaust connections in the pool. This can be done with `ActiveRecord::Base.connection_pool.with_connection`, which ensures the connection is returned back to the pool when completed.


```Ruby
# app/workers/awesome_worker.rb

class AwesomeWorker
  include SuckerPunch::Worker

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
class AwesomeWorker
  include SuckerPunch::Worker

  def perform(user_id)
    ActiveRecord::Base.connection_pool.with_connection do
      user = User.find(user_id)
      user.update_attributes(is_awesome: true)
      SuckerPunch::Queue[:log_queue].async.perform("User #{user.id} became awesome!")
    end
  end
end
```

Queues:

```Ruby
SuckerPunch::Queue[:log_queue] # Just a wrapper for the LogWorker class
SuckerPunch::Queue.new(:log_queue)
```

Synchronous:

```Ruby
SuckerPunch::Queue[:log_queue].perform("login")
```

Asynchronous:

```Ruby
SuckerPunch::Queue[:log_queue].async.perform("login") # => nil
```

## Stats

```Ruby
SuckerPunch::Queue[:log_queue].workers # => 7
SuckerPunch::Queue[:log_queue].busy_size # => 4
SuckerPunch::Queue[:log_queue].idle_size # => 3
```

## Testing

```Ruby
# spec/spec_helper.rb
require 'sucker_punch/testing'
```

Requiring this library completely stubs out the internals of Sucker Punch, but will provide the necessary tools to confirm your jobs are being enqueud.

```Ruby
# spec/spec_helper.rb
require 'sucker_punch/testing'

RSpec.configure do |config|
  config.after do
    SuckerPunch.reset! # => Resets the queues and jobs in the queues before each test
  end
end

# config/initializer/sucker_punch.rb
SuckerPunch.config do
  queue name: :email, worker: EmailWorker, workers: 2
end

# app/workers/email_worker.rb
class EmailWorker
  include SuckerPunch::Worker

  def perform(email, user_id)
    user = User.find(user_id)
    UserMailer.send(email.to_sym, user)
  end
end

# spec/models/user.rb
class User < ActiveRecord::Base
  def send_welcome_email
    SuckerPunch::Queue.new(:email).async.perform(:welcome, self.id)
  end
end

# spec/models/user_spec.rb
require 'spec_helper'

describe User do
  describe "#send_welcome_email" do
    user = FactoryGirl.create(:user)
    expect{
      user.send_welcome_email
     }.to change{ SuckerPunch::Queue.new(:email).jobs.size }.by(1)
  end
end
```

```Ruby
# spec/spec_helper.rb
require 'sucker_punch/testing/inline'
```

Requiring this library causes your workers to run everything inline. So a call to the following will actually be SYNCHRONOUS.

```Ruby
SuckerPunch::Queue[:log_queue].async.perform("login")
```

## Troubleshooting

If you're running tests in transactions (using DatabaseCleaner or a native solution), Sucker Punch workers may have trouble finding database records that were created during test setup because the worker class is running in a separate thread and the Transaction operates on a different thread so it clears out the data before the worker can do its business. The best thing to do is cleanup data created for tests workers through a truncation strategy by tagging the rspec tests as workers and then specifying the strategy in `spec_helper` like below:

```Ruby
# spec/spec_helper.rb
RSpec.configure do |config|
  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  # Clean up all worker specs with truncation
  config.before(:each, :worker => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

# spec/workers/email_worker_spec.rb
require 'spec_helper'

# Tag the spec as a worker spec so data is persisted long enough for the test
describe EmailWorker, worker: true do
  describe "#perform" do
    let(:user) { FactoryGirl.create(:user) }

    it "delivers an email" do
      expect {
        EmailWorker.new.perform(user.id)
      }.to change{ ActionMailer::Base.deliveries.size }.by(1)
    end
  end
end
```

When using Passenger or Unicorn, you should configure the queues within a block that runs after the child process is forked.

```Ruby
# config/unicorn.rb
#
# The following is only need if in your unicorn config
# you set:
# preload_app true
after_fork do |server, worker|
  SuckerPunch.config do
    queue name: :log_queue, worker: LogWorker, workers: 10
  end
end
```
```Ruby
# config/initializers/sucker_punch.rb
#
if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    SuckerPunch.config do
      queue name: :log_queue, worker: LogWorker, workers: 10
    end
  end
end
```

## Gem Name

...is awesome. But I can't take credit for it. Thanks to [@jmazzi](https://twitter.com/jmazzi) for his superior naming skills. If you're looking for a name for something, he is the one to go to.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
