module SuckerPunch
  module Queue
    extend self

    def [](name)
      Celluloid::Actor[name]
    end
  end
end