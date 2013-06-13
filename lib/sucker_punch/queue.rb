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

    # Equivalent to size of the Celluloid Pool
    # However, in context of a "queue" workers
    # makes more sense here
    def workers
      Celluloid::Actor[name].size
    end

    # Equivalent to number of messages queued
    # in the Celluloid mailbox
    def size
      Celluloid::Actor[name].mailbox.size
    end

    def method_missing(method_name, *args, &block)
      Celluloid::Actor[name].send(method_name, *args, &block)
    end
  end
end
