module RServiceBus2
  # Subscription Manager
  class SubscriptionManager
    def initialize(subscription_storage)
      @subscription_storage = subscription_storage
      @subscriptions = @subscription_storage.get_all
    end

    # Get subscriptions for given eventName
    def get(event_name)
      subscriptions = @subscriptions[event_name]
      if subscriptions.nil?
        RServiceBus2.log "No subscribers for event, #{event_name}"
        RServiceBus2.log "If there should be, ensure you have the appropriate evironment variable set, eg MESSAGE_ENDPOINT_MAPPINGS=#{event_name}:<Queue Name>"
        return []
      end

      subscriptions
    end

    def add(event_name, queue_name)
      RServiceBus2.log 'Adding subscription for, ' +
        event_name + ', to, ' + queue_name
      @subscriptions = @subscription_storage.add(event_name, queue_name)
    end

    def remove(_event_name, _queue_name)
      fail 'Method, remove, needs to be implemented for this subscription storage'
    end
  end
end
