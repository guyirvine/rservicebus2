require 'uri'

module RServiceBus2
  # Base class for subscription storage
  class SubscriptionStorage
    # Constructor
    # @param [String] app_name Name of the application, which is used as a
    #  Namespace
    # @param [String] uri a location for the resource to which we will attach,
    #  eg redis://127.0.0.1/foo
    def initialize(app_name, uri)
      @app_name = app_name
      @uri = uri
    end

    # Get a list of all subscription, as an Array
    def get_all
      fail 'Method, get_all, needs to be implemented for SubscriptionStorage'
    end

    # Add a new subscription
    # @param [String] event_name Name of the event for which the subscriber
    #  has asked for notification
    # @param [String] queue_name the queue to which the event should be sent
    def add(_event_name, _queue_name)
      fail 'Method, add, needs to be implemented for this subscription storage'
    end

    # Remove an existing subscription
    #
    # @param [String] event_name Name of the event for which the subscriber
    #  has asked for notification
    # @param [String] queue_name the queue to which the event should be sent
    def remove(_event_name, _queue_name)
      fail 'Method, remove, needs to be implemented for this subscription
        storage'
    end
  end
end
