module RServiceBus

  # Error Message
  class ErrorMessage
    attr_reader :occurredat, :source_queue, :error_msg

    def initialize(source_queue, error_msg)
      @occurredat = DateTime.now

      @source_queue = source_queue
      @error_msg = error_msg
    end
  end
end
