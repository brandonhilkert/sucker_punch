require 'test_helper'

class SuckerPunchTest < Minitest::Test
  def teardown
    SuckerPunch.logger = nil
    SuckerPunch.exception_handler { |ex, klass, args| SuckerPunch.default_handler(ex, klass, args) }
    SuckerPunch.shutdown_mode = :soft
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

  def test_default_exception_handler_is_logger
    @mock = Minitest::Mock.new
    SuckerPunch.logger = @mock
    @mock.expect(:error, nil, ["Sucker Punch job error for class: '' args: []\nStandardError fake\n"])
    SuckerPunch.handler.call(StandardError.new("fake"), '', [])
    @mock.verify
  end

  def test_exception_handler_can_be_set
    SuckerPunch.exception_handler { |ex, _, _| raise "bad stuff" }
    assert_raises(::RuntimeError) { SuckerPunch.handler.call }
  end

  def test_handler_yields_to_whats_passed
    SuckerPunch.exception_handler { |ex, klass, args| FakeHandler.new.handle(ex, klass, args) }
    assert_equal ["fake", nil, []], SuckerPunch.handler.call("fake", nil, [])
  end

  def test_default_shutdown_mode_is_soft
    SuckerPunch.shutdown_mode = nil
    assert_equal :soft, SuckerPunch.shutdown_mode
  end

  def test_can_set_shutdown_mode
    SuckerPunch.shutdown_mode = :hard
    assert_equal :hard, SuckerPunch.shutdown_mode
  end

  private

  class FakeHandler
    def handle(ex, klass, args); [ex, klass, args]; end
  end
end

