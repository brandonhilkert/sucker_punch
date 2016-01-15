module SuckerPunch
  module Counter
    module Utilities
      def value
        @counter.value
      end

      def increment
        @counter.increment
      end

      def decrement
        @counter.decrement
      end
    end

    class Busy
      attr_reader :counter

      include Utilities

      COUNTER = Concurrent::Map.new do |hash, name|
        hash.compute_if_absent(name) { Concurrent::AtomicFixnum.new }
      end

      def self.clear
        COUNTER.clear
      end

      def initialize(queue_name)
        @counter = COUNTER[queue_name]
      end
    end

    class Processed
      attr_reader :counter

      include Utilities

      COUNTER = Concurrent::Map.new do |hash, name|
        hash.compute_if_absent(name) { Concurrent::AtomicFixnum.new }
      end

      def self.clear
        COUNTER.clear
      end

      def initialize(queue_name)
        @counter = COUNTER[queue_name]
      end
    end

    class Failed
      attr_reader :counter

      include Utilities

      COUNTER = Concurrent::Map.new do |hash, name|
        hash.compute_if_absent(name) { Concurrent::AtomicFixnum.new }
      end

      def self.clear
        COUNTER.clear
      end

      def initialize(queue_name)
        @counter = COUNTER[queue_name]
      end
    end
  end
end

