require 'sucker_punch'
require 'celluloid/proxy/abstract'
require 'celluloid/proxy/sync'
require 'celluloid/proxy/actor'

class Celluloid::Proxy::Cell < Celluloid::Proxy::Sync
  def async(method_name = nil, *args, &block)
    self
  end
end

