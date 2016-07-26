module RServiceBus2
  class MessageArrivedWhileCricuitBroken < StandardError
  end

  # An implementation of Michael Nygard's Circuit Breaker pattern.
  class CircuitBreaker
    def reset
      @broken = false

      @number_of_failures = 0
      @time_of_first_failure = nil

      @time_to_break = nil
      @time_to_reset = nil
    end

    def initialize(host)
      @host = host
      @maxnumber_of_failures = RServiceBus2.get_value('RSBCB_MAX', 5)
      @seconds_to_break = RServiceBus2.get_value('RSBCB_SECONDS_TO_BREAK', 60).to_i
      @seconds_to_reset = RServiceBus2.get_value('RSBCB_SECONDS_TO_RESET', 60).to_i
      @reset_on_success = RServiceBus2.get_value('RSBCB_RESET_ON_SUCCESS', false)

      reset
    end

    ####### Public Interface
    # Broken will be called before processing a message.
    #  => Broken will be called before Failure
    def broken
      reset if !@time_to_reset.nil? && Time.now > @time_to_reset
      @broken
    end

    def live
      !broken
    end

    ## This should be called less than success.
    ## If there is a failure, then taking a bit longer gives time to settle.
    def failure
      message_arrived

      ## logFirstFailure
      if @number_of_failures == 0
        @number_of_failures = 1
        @time_of_first_failure = Time.now
        @time_to_break = @time_of_first_failure + @seconds_to_break
      else
        @number_of_failures += 1
      end

      ## checkToBreakCircuit
      break_circuit if @number_of_failures >= @maxnumber_of_failures
    end

    def success
      if @reset_on_success == true
        reset
        return
      end

      message_arrived
    end

    protected

    def message_arrived
      reset if !@time_to_break.nil? && Time.now > @time_to_break

      fail MessageArrivedWhileCricuitBroken if @broken == true
    end

    def break_circuit
      @broken = true
      @time_to_reset = Time.now + @seconds_to_reset
    end
  end
end
