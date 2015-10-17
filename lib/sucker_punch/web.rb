require 'erb'
require 'sinatra/base'

require 'sucker_punch'

module SuckerPunch
  class Web < Sinatra::Base
    # enable :sessions
    # use Rack::Protection, :use => :authenticity_token unless ENV['RACK_ENV'] == 'test'

    set :root, File.expand_path(File.dirname(__FILE__) + "/../../web")
    set :public_folder, proc { "#{root}/assets" }
    set :views, proc { "#{root}/views" }

    def root_path
      "#{env['SCRIPT_NAME']}/"
    end

    get '/' do
      erb :dashboard
    end

    get '/stats' do
      stats = SuckerPunch::Queue.all
      content_type :json
      stats.to_json
    end
  end
end
