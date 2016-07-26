module RServiceBus2
  # User Message
  class UserMessageWithPayload
    attr_reader :payload

    def initialize(payload)
      @payload = payload
    end
  end
end
