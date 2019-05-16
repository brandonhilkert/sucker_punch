require 'sucker_punch'

# Include this in your tests to simulate
# a fake job queue. Jobs won't be executed
# as they normal would be the thread pool.
# They'll instead be pushed to a fake queue
# to be checked in a test environment.
#
# Include in your test_helper.rb:
#
# require 'sucker_punch/testing'
#
# In your application code:
#
#   LogJob.perform_async(1, 2, 3)
#
# In your tests:
#
#   LogJob.jobs => [{ "args" => [1, 2, 3]]

module SuckerPunch
  module Job
    def self.jobs
      SuckerPunch::Queue.find_or_create(self.to_s)
    end

    def self.clear_all

    end
  end

  class Queue
    def self.find_or_create(name, number_workers = 2, num_jobs_max = nil)
      QUEUES.fetch_or_store(name) do
        []
      end
    end


    def kill
      true
    end
  end
end
