module SuckerPunch
  class Queues
    @queues = Set.new

    def self.all
      @queues.to_a
    end

    def self.register(name)
      @queues.add(name)
    end

    def self.registered?(name)
      @queues.include?(name)
    end
  end
end

