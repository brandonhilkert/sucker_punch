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
      Celluloid::Actor[name] = if size
                                  klass.send(:pool, size: size)
                                else
                                  klass.send(:pool)
                                end
    end

    def workers
      size
    end

    def method_missing(method_name, *args, &block)
      Celluloid::Actor[name].send(method_name, *args, &block)
    end
  end
end
