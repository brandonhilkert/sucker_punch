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
  #   LogJob.perform_in(60, 1, 2, 3) # `perform` will be executed 60 sec. later
  #
  # Note that perform_async is a class method, perform is an instance method.
  module Job
    def self.included(base)
      base.extend(ClassMethods)
      base.class_attribute :num_workers
      base.class_attribute :num_jobs_max

      base.num_workers = 2
      base.num_jobs_max = nil
    end

    def logger
      SuckerPunch.logger
    end

    module ClassMethods
      def perform_async(*args)
        return unless SuckerPunch::RUNNING.true?
        queue = SuckerPunch::Queue.find_or_create(self.to_s, num_workers, num_jobs_max)
        queue.post { __run_perform(self.to_s, *args) }
      end
      ruby2_keywords(:perform_async) if respond_to?(:ruby2_keywords, true)

      def perform_in(interval, *args)
        return unless SuckerPunch::RUNNING.true?
        queue = SuckerPunch::Queue.find_or_create(self.to_s, num_workers, num_jobs_max)
        job = Concurrent::ScheduledTask.execute(interval.to_f, args: args, executor: queue) do
          __run_perform(self.to_s, *args)
        end
        job.pending?
      end
      ruby2_keywords(:perform_in) if respond_to?(:ruby2_keywords, true)

      def perform_through(options, *args)
        return unless SuckerPunch::RUNNING.true?
        queue_name = options[:queue] || self.to_s
        workers_count = options[:workers] || 1
        max_jobs = options[:max_jobs]
        queue = SuckerPunch::Queue.find_or_create(queue_name, workers_count, max_jobs)
        queue.post { __run_perform(queue_name, *args) }
      end
      ruby2_keywords(:perform_through) if respond_to?(:ruby2_keywords, true)

      def workers(num)
        self.num_workers = num
      end

      def max_jobs(num)
        self.num_jobs_max = num
      end

      def __run_perform(queue, *args)
        SuckerPunch::Counter::Busy.new(queue).increment

        result = self.new.perform(*args)

        SuckerPunch::Counter::Processed.new(queue).increment
        result
      rescue => ex
        SuckerPunch::Counter::Failed.new(queue).increment
        SuckerPunch.exception_handler.call(ex, self, [*args])
      ensure
        SuckerPunch::Counter::Busy.new(queue).decrement
      end
      ruby2_keywords(:__run_perform) if respond_to?(:ruby2_keywords, true)
    end
  end
end
