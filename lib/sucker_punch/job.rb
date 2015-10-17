module SuckerPunch
  # Include this module in your job class
  # to create asynchronous jobs:
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
  # Note that perform_async is a class method, perform is an instance method.
  module Job
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def perform_async(*args)
        queue = SuckerPunch::Queue::QUEUES[self.to_s]
        queue.post(args) { |args| self.new.perform(*args) }
      end

      def perform_in(interval, *args)
        job = Concurrent::ScheduledTask.execute(interval.to_f, args: args, executor: SuckerPunch::Queue::QUEUES[self.to_s]) do |args|
          self.new.perform(*args)
        end
        job.pending?
      end
    end
  end
end
