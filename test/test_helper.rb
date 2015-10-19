$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sucker_punch'

require 'pry'
require 'minitest/autorun'
require 'minitest/pride'

SuckerPunch.logger = nil
