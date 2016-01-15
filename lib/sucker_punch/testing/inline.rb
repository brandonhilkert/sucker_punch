require 'sucker_punch'

# Include this in your tests to simulate
# immediate execution of your asynchronous jobs
#
# class LogJob
#   include SuckerPunch::Job
#
#   def perform(*args)
#     # log the things
#   end
# end
#
# To trigger asynchronous job:
#
#   LogJob.perform_async(1, 2, 3)
#
# Include inline testing lib:
#
# require 'sucker_punch/testing/inline"
#
# LogJob.perform_async(1, 2, 3) is now synchronous
# LogJob.perform_in(1, 2, 3) is now synchronous
#
module SuckerPunch
  module Job
    module ClassMethods
      def perform_async(*args)
        self.new.perform(*args)
      end

      def perform_in(_, *args)
        self.new.perform(*args)
      end
    end
  end
end
