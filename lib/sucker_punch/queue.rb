require 'thread'

module SuckerPunch
  class Queue
    attr_reader :klass
    attr_accessor :pool

    DEFAULT_OPTIONS = { workers: 2 }
    PREFIX = "sucker_punch"
    class MaxWorkersExceeded < StandardError; end
    class NotEnoughWorkers < StandardError; end

    def self.find(klass)
      queue = self.new(klass)
      Celluloid::Actor[queue.name]
    end

    def self.clear_all
      Celluloid::Actor.all.each do |actor|
        registered_name = actor.registered_name.to_s
        matches = registered_name.match(PREFIX).to_a

        if matches.any?
          Celluloid::Actor.delete(registered_name)
        end
      end
    end

    def initialize(klass)
      @klass = klass
      @pool = nil
      @mutex = Mutex.new
    end

    def register(num_workers = DEFAULT_OPTIONS[:workers])
      num_workers ||= DEFAULT_OPTIONS[:workers]
      raise MaxWorkersExceeded if num_workers > 200
      raise NotEnoughWorkers if num_workers < 1

      @mutex.synchronize {
        unless registered?
          initialize_celluloid_pool(num_workers)
          register_celluloid_pool
        end
      }
      self.class.find(klass)
    end

    def registered?
      Celluloid::Actor.registered.include?(name.to_sym)
    end

    def name
      klass_name = klass.to_s.underscore
      "#{PREFIX}_#{klass_name}".to_sym
    end

    private

    def initialize_celluloid_pool(num_workers)
      self.pool = klass.send(:pool, { size: num_workers })
    end

    def register_celluloid_pool
      Celluloid::Actor[name] = pool
    end
  end
end


