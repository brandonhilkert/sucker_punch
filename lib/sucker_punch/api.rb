module SuckerPunch
  class API
    class Queues
      @queues = Set.new

      def self.all
        @queues.to_a
      end

      def self.register(name)
        @queues.add(name)
      end
    end
  end
end

