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
