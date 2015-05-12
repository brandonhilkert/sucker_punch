module SuckerPunch
  class Railtie < ::Rails::Railtie
    initializer "sucker_punch.logger" do
      SuckerPunch.logger = Rails.logger
    end

    config.to_prepare do
      SuckerPunch.clear_queues
    end
  end
end
