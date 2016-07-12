module RServiceBus
  # Class to hold message subscriptions
  class MessageSubscription
    attr_reader :event_name

    def initialize(event_name)
      @event_name = event_name
    end
  end
end
