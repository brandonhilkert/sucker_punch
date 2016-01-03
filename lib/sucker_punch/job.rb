module SuckerPunch
  # Include this module in your job class
  # to create asynchronous jobs:
  #
  # class LogJob
  #   include SuckerPunch::Job
  #   workers 4
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
      base.class_attribute :num_workers

      base.num_workers = 2
    end

    def logger
      SuckerPunch.logger
    end

    module ClassMethods
      def perform_async(*args)
        if SuckerPunch::RUNNING.true?
          queue = SuckerPunch::Queue.find_or_create(self.to_s, num_workers)
          queue.pool.post(args) { |args| __run_perform(*args) }
        end
      end

      def perform_in(interval, *args)
        if SuckerPunch::RUNNING.true?
          queue = SuckerPunch::Queue.find_or_create(self.to_s, num_workers)
          job = Concurrent::ScheduledTask.execute(interval.to_f, args: args, executor: queue.pool) do |args|
            # check when the job actually runs in case the job is post during shutdown
            if SuckerPunch::RUNNING.true?
              self.new.perform(*args)
            end
          end
          job.pending?
        end
      end

      def workers(num)
        self.num_workers = num
      end

      def __run_perform(*args)
        SuckerPunch::Counter::Busy.new(self.to_s).increment
        result = self.new.perform(*args)
        SuckerPunch::Counter::Processed.new(self.to_s).increment
        result
      rescue => ex
        SuckerPunch::Counter::Failed.new(self.to_s).increment
        SuckerPunch.handler.call(ex, self, args)
      ensure
        SuckerPunch::Counter::Busy.new(self.to_s).decrement
      end
    end
  end
end
