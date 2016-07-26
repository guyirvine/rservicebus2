require 'minitest/autorun'
require './lib/rservicebus2/CircuitBreaker.rb'
require './lib/rservicebus2/helper_functions.rb'
require './Mock/Host.rb'

# Test Cricuit Breaker
class TestCircuitBreaker < RServiceBus2::CircuitBreaker
  # @maxNumberOfFailures = RServiceBus2.getValue( "RSBCB_MAX", 5 )
  # @secondsToBreak = RServiceBus2.getValue( "RSBCB_SECONDS_TO_BREAK", 60 ).to_i
  # @secondsToReset = RServiceBus2.getValue( "RSBCB_SECONDS_TO_RESET", 60 ).to_i
  # @resetOnSuccess = RServiceBus2.getValue( "RSBCB_RESET_ON_SUCCESS", false )
  attr_accessor :seconds_to_break, :seconds_to_reset, :time_to_reset
end

# Cricuit Breaker Test
class CircuitBreakerTest < Minitest::Test
  def setup
    ENV['TESTING'] = 'TRUE'
  end

  def test_OneSuccessNotBroken
    cb = TestCircuitBreaker.new(RServiceBus2::MockHost.new)
    cb.success
    assert_equal true, cb.live
  end

  def test_TwoSuccessNotBroken
    cb = TestCircuitBreaker.new(RServiceBus2::MockHost.new)

    cb.success
    assert_equal true, cb.live

    cb.success
    assert_equal true, cb.live
  end

  def test_FailureOneOfFiveNotBroken
    cb = TestCircuitBreaker.new(RServiceBus2::MockHost.new)

    cb.failure
    assert_equal true, cb.live
  end

  def test_FailureTwoOfFiveNotBroken
    cb = TestCircuitBreaker.new(RServiceBus2::MockHost.new)

    cb.failure
    assert_equal true, cb.live

    cb.failure
    assert_equal true, cb.live
  end

  def test_FailureFiveOfFiveBroken
    cb = TestCircuitBreaker.new(RServiceBus2::MockHost.new)

    cb.failure
    assert_equal true, cb.live

    cb.failure
    assert_equal true, cb.live

    cb.failure
    assert_equal true, cb.live

    cb.failure
    assert_equal true, cb.live

    cb.failure
    assert_equal false, cb.live
  end

  def test_FailureFiveOfFiveOutsideWindowNotBroken
    cb = TestCircuitBreaker.new(RServiceBus2::MockHost.new)
    cb.seconds_to_break = 0.1

    cb.failure
    assert_equal true, cb.live

    cb.failure
    assert_equal true, cb.live

    cb.failure
    assert_equal true, cb.live

    cb.failure
    assert_equal true, cb.live

    sleep 0.2

    cb.live
    cb.failure
    assert_equal true, cb.live
  end

  def test_FailureFiveOfFiveBrokenThenFailureBeforeReset
    cb = TestCircuitBreaker.new(RServiceBus2::MockHost.new)
    cb.seconds_to_reset = 0.1

    cb.failure
    assert_equal true, cb.live

    cb.failure
    assert_equal true, cb.live

    cb.failure
    assert_equal true, cb.live

    cb.failure
    assert_equal true, cb.live

    cb.failure
    assert_equal false, cb.live

    sleep 0.2

    exception_raised = false
    begin
      cb.failure
    rescue RServiceBus2::MessageArrivedWhileCricuitBroken
      exception_raised = true
    end
    assert_equal true, exception_raised
  end

  def test_FailureFiveOfFiveBrokenThenReset
    cb = TestCircuitBreaker.new(RServiceBus2::MockHost.new)
    cb.seconds_to_reset = 0.1

    cb.failure
    assert_equal true, cb.live

    cb.failure
    assert_equal true, cb.live

    cb.failure
    assert_equal true, cb.live

    cb.failure
    assert_equal true, cb.live

    cb.failure
    assert_equal false, cb.live

    sleep 0.5

    assert_equal true, cb.live
  end
end
