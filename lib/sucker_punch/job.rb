module SuckerPunch
  module Job
    def self.included(base)
      base.send(:include, ::Celluloid)
      base.extend(ClassMethods)

      base.class_eval do
        @workers = SuckerPunch::Queue::DEFAULT_OPTIONS[:workers]

        def self.new
          define_celluloid_pool(self, @workers)
        end
      end
    end

    module ClassMethods
      def workers(num)
        @workers = num
      end

      def define_celluloid_pool(klass, workers)
        SuckerPunch::Queue.new(klass).register(workers)
      end
    end

  end
end
