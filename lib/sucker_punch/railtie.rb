module SuckerPunch
  class Railtie < ::Rails::Railtie
    initializer "sucker_punch.logger" do
      SuckerPunch.logger = Rails.logger
    end
  end
end
