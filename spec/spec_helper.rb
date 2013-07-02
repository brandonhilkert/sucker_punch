begin
  require 'pry'
rescue LoadError
end

require 'sucker_punch'

RSpec.configure do |config|
  config.after(:each) do
    # Clean up the master queue list
    SuckerPunch::Queues.instance_variable_set(:@queues, Set.new)
  end
end
