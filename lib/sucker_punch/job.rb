module SuckerPunch
  module Job
    def self.included(base)
      base.send(:include, ::Celluloid)
      base.extend(ClassMethods)

      base.class_eval do
        def self.new
          define_celluloid_pool(self, @workers)
        end
      end
    end

    module ClassMethods
      def workers(num)
        @workers = num
      end

      def define_celluloid_pool(klass, num_workers)
        SuckerPunch::Queue.new(klass).register(num_workers)
      end
    end

  end
end
