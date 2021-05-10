# frozen_string_literal: true

module RServiceBus2
  # Error Message
  class ErrorMessage
    attr_reader :occurredat, :source_queue, :error_msg

    def initialize(source_queue, error_msg)
      @occurredat = Time.now

      @source_queue = source_queue
      @error_msg = error_msg
    end
  end
end
