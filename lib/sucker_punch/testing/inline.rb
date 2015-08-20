require 'sucker_punch'
require "celluloid/proxy/abstract"
require "celluloid/proxy/sync"
require "celluloid/proxy/actor"

module Celluloid
  class CellProxy < SyncProxy
    def async(method_name = nil, *args, &block)
      self
    end
  end
end

