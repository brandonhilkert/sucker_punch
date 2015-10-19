require 'test_helper'

class SuckerPunchTest < Minitest::Test
  def teardown
    SuckerPunch.logger = nil
  end

  def test_that_it_has_a_version_number
    refute_nil ::SuckerPunch::VERSION
  end

  def test_logger_defaults_to_stdout
    SuckerPunch.logger = SuckerPunch.default_logger
    assert SuckerPunch.logger.is_a?(Logger)
    assert_equal Logger::INFO, SuckerPunch.logger.level
  end

  def test_can_reset_logger
    SuckerPunch.logger = nil
    assert SuckerPunch.logger.is_a?(Logger)
  end

  def test_logger_can_be_set
    logger = Logger.new(nil)
    SuckerPunch.logger = logger
    assert_equal logger, SuckerPunch.logger
  end

  def test_exception_handler_can_be_set
    SuckerPunch.exception_handler { |ex| raise "bad stuff" }
    assert_raises(::RuntimeError) { SuckerPunch.handler.call }
  end

  def test_handler_yields_to_whats_passed
    SuckerPunch.exception_handler { |ex| FakeHandler.new.handle(ex) }
    assert_equal "fake", SuckerPunch.handler.call("fake")
  end

  private

  class FakeHandler
    def handle(ex); ex; end
  end
end

