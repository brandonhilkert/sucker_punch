module SuckerPunch
  class << self
    attr_accessor :queues

    def reset!
      self.queues = {}
    end
  end

  SuckerPunch.reset!

  class Queue
    attr_reader :name

    def initialize(name)
      @name = name
      SuckerPunch.queues[name] ||= []
    end

    def self.[](name)
      new(name)
    end

    def register(klass, size, args=nil)
      nil
    end

    def workers
      raise "Not implemented"
    end

    def jobs
      SuckerPunch.queues[@name]
    end

    def async
      self
    end

    def method_missing(name, *args, &block)
      SuckerPunch.queues[@name] << { method: name, args: Array(args) }
    end
  end
end
