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
  #   LogJob.perform_in(60, 1, 2, 3) # `perform` will be excuted 60 sec. later
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
        return unless SuckerPunch::RUNNING.true?
        queue = SuckerPunch::Queue.find_or_create(self.to_s, num_workers)
        queue.post(args) { |args| __run_perform(*args) }
      end

      def perform_in(interval, *args)
        return unless SuckerPunch::RUNNING.true?
        queue = SuckerPunch::Queue.find_or_create(self.to_s, num_workers)
        job = Concurrent::ScheduledTask.execute(interval.to_f, args: args, executor: queue) do
          __run_perform(*args)
        end
        job.pending?
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
        SuckerPunch.exception_handler.call(ex, self, args)
      ensure
        SuckerPunch::Counter::Busy.new(self.to_s).decrement
      end
    end
  end
end
