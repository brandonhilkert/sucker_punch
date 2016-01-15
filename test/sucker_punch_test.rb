require 'test_helper'

class SuckerPunchTest < Minitest::Test
  def setup
    SuckerPunch::Queue.clear
  end

  def teardown
    SuckerPunch::Queue.clear
    SuckerPunch.logger = nil
    SuckerPunch.exception_handler = nil
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
    SuckerPunch.exception_handler.call(StandardError.new("fake"), '', [])
    assert @mock.verify
  end

  def test_exception_handler_can_be_set
    SuckerPunch.exception_handler = -> (ex, _, _) { raise "bad stuff" }
    assert_raises(::RuntimeError) { SuckerPunch.exception_handler.call(StandardError.new("bad"), nil, nil) }
  end

  def test_shutdown_timeout_can_be_set
    SuckerPunch.shutdown_timeout = 15
    assert_equal 15, SuckerPunch.shutdown_timeout
  end
end
