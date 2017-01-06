module SuckerPunch
  module Job
    def async
      AsyncProxy.new(self)
    end

    def later(sec, *args)
      self.class.perform_in(sec, *args)
    end
  end

  class AsyncProxy
    def initialize(job)
      @job = job
    end

    def perform(*args)
      @job.class.perform_async(*args)
    end

    def method_missing(name, *args)
      raise NoMethodError.new("undefined method '#{name}' for #{inspect}:#{self.class}") unless @job.respond_to?(name)
      @job.send(name, *args)
    end
  end
end
