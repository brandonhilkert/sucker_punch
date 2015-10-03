require 'sucker_punch'
require "celluloid/proxy/sync"
require "celluloid/proxy/async"
require "celluloid/proxy/cell"

module Celluloid
  module Proxy
    class Cell < Sync
      def async(method_name = nil, *args, &block)
        self
      end
    end
  end
end

