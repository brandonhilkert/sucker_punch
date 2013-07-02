module SuckerPunch
  module Job
    def self.included(base)
      base.send(:include, ::Celluloid)
      base.extend(ClassMethods)

      base.class_eval do
        def self.new
          define_celluloid_pool(self)
        end
      end
    end

    module ClassMethods
      def define_celluloid_pool(klass)
        SuckerPunch::Queue.new(klass).register
      end
    end

  end
end
