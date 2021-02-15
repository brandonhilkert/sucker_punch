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

    def perform(*args, **kwargs)
      @job.class.perform_async(*args, **kwargs)
    end
  end
end
