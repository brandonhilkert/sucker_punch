module SuckerPunch
  module Job
    def self.included(base)
      base.send(:include, ::Celluloid)
      base.class_eval do
        # set up a callback to SuckerPunch::Job
        # whenever a method is defined on the base class
        def self.method_added(m)
          SuckerPunch::Job.realias_methods(self) if m == :perform
        end
      end
    end

    def perform_with_pool_check(*args, &block)
      define_celluloid_pool
      perform_without_pool_check(*args, &block)
    end

    private

    def self.realias_methods(base)
      # the icky bit prevents an infinite loop
      # otherwise aliasing :perform_with_pool_check to :perform
      # counts will trigger another call to method_added
      if !@icky_bit
        @icky_bit = true
        base.class_eval do
          alias_method :perform_without_pool_check, :perform
          alias_method :perform, :perform_with_pool_check
        end
        remove_instance_variable :@icky_bit
      end
    end

    def define_celluloid_pool
      queue = SuckerPunch::Queue.new(self)
      queue.register
    end

  end
end
