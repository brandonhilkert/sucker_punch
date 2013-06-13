module SuckerPunch
  class Queue
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def self.[](name)
      Celluloid::Actor[name]
    end

    def register(klass, size)
      opts = {}
      opts[:size] = size if size
      Celluloid::Actor[name] = klass.send(:pool, opts)
    end

    def workers
      size
    end

    def method_missing(method_name, *args, &block)
      Celluloid::Actor[name].send(method_name, *args, &block)
    end
  end
end
