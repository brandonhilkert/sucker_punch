module SuckerPunch
  module Job
    def async
      AsyncProxy.new(self)
    end
  end

  class AsyncProxy
    def initialize(job)
      @job = job
    end

    def perform(*args)
      @job.class.perform_async(*args)
    end
  end
end

