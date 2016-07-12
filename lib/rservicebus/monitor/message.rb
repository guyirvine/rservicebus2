module RServiceBus
  # Monitor Message
  class MonitorMessage
    attr_reader :payload, :uri

    def initialize(payload, uri)
      @payload = payload
      @uri = uri
    end
  end
end
