module SuckerPunch
  module Worker
    def self.included(base)
      base.send :include, ::Celluloid
    end
  end
end