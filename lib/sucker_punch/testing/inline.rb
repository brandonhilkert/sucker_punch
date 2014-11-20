require "celluloid/proxies/abstract_proxy"
require "celluloid/proxies/sync_proxy"
require "celluloid/proxies/actor_proxy"

module Celluloid
  class CellProxy < SyncProxy
    def async(method_name = nil, *args, &block)
      self
    end
  end
end

