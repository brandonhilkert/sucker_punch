require 'sucker_punch/counter/utilities'

module SuckerPunch
  module Counter
    class Failed
      attr_reader :counter

      include SuckerPunch::Counter::Utilities

      COUNTER = Concurrent::Map.new do |hash, name| #:nodoc:
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
