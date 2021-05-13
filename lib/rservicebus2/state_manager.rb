# frozen_string_literal: true

require 'rservicebus2/state_storage'

module RServiceBus2
  # State Manager
  class StateManager
    def required
      # Check if the State Dir has been specified
      # If it has, make sure it exists, and is writable

      string = RServiceBus2.get_value('STATE_URI')
      string = 'dir:///tmp' if string.nil?

      uri = URI.parse(string)
      @state_storage = StateStorage.get(uri)
    end

    def begin
      @state_storage&.begin
    end

    def get(handler)
      @state_storage&.get(handler)
    end

    def commit
      @state_storage&.commit
    end
  end
end
