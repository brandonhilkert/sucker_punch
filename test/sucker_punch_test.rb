require 'test_helper'

module SuckerPunchTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::SuckerPunch::VERSION
  end
end

