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

`config/initializers/sucker_punch.rb`

```Ruby
  SuckerPunch.config do
    queue name: :log_queue, worker: LogWorker, size: 10
    queue name: :awesome_queue, worker: AwesomeWorker, size: 2
  end
```

## Usage

`app/workers/log_worker.rb`

```Ruby
class LogWorker
  include SuckerPunch::Worker

  def perform(event)
    Log.new(event).track
  end
end
```

All workers should define an instance method `perform`, of which the job being queued will adhere to.

Workers interacting with `ActiveRecord` should take special precaution not to exhaust connections in the pool. This can be done with `ActiveRecord::Base.connection_pool.with_connection`, which ensures the connection is returned back to the pool when completed.

`app/workers/awesome_worker.rb`

```Ruby
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
SuckerPunch::Queue[:log_queue].size # => 7
SuckerPunch::Queue[:log_queue].busy_size # => 4
SuckerPunch::Queue[:log_queue].idle_size # => 3
```

## Testing

`spec/spec_helper.rb`
```Ruby
require 'sucker_punch/testing/inline'
```

Requiring this library causes your workers to run everything inline. So a call to the following will actually be SYNCHRONOUS.

```Ruby
SuckerPunch::Queue[:log_queue].async.perform("login")
```

## Gem Name

...is awesome. But I can't take credit for it. Thanks to [@jmazzi](https://twitter.com/jmazzi) for his superior naming skills. If you're looking for a name for something, he is the one to go to.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
