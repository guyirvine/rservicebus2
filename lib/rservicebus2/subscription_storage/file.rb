module RServiceBus2
  # Implementation of Subscription Storage to Redis
  class SubscriptionStorageFile < SubscriptionStorage
    # Constructor
    #
    # @param [String] app_ame Name of the application, used as a Namespace
    # @param [String] uri resource location to attach, eg redis://127.0.0.1/foo
    def initialize(app_name, uri)
      super(app_name, uri)
    end

    def get_all
      RServiceBus.log 'Load subscriptions'
      return {} unless File.exist?(@uri.path)

      YAML.load(File.open(@uri.path))
    end

    def add(event_name, queue_name)
      # s => subscriptions
      if File.exist?(@uri.path)
        s = YAML.load(File.open(@uri.path))
      else
        s = {}
      end

      s[event_name] = [] if s[event_name].nil?

      s[event_name] << queue_name
      s[event_name] = s[event_name].uniq

      File.open(@uri.path, 'w') { |f| f.write(YAML.dump(s)) }

      s
    end

    def remove(_event_name, _queue_name)
      fail 'Method, remove, needs to be implemented for this
            subscription storage'
    end
  end
end
