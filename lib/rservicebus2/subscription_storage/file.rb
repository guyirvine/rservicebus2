# frozen_string_literal: true

module RServiceBus2
  # Implementation of Subscription Storage to Redis
  class SubscriptionStorageFile < SubscriptionStorage
    def all
      RServiceBus2.log 'Load subscriptions'
      return {} unless File.exist?(@uri.path)

      YAML.load(File.open(@uri.path))
    end

    def add(event_name, queue_name)
      s = File.exist?(@uri.path) ? YAML.load(File.open(@uri.path)) : {}
      s[event_name] = [] if s[event_name].nil?

      s[event_name] << queue_name
      s[event_name] = s[event_name].uniq

      File.open(@uri.path, 'w') { |f| f.write(YAML.dump(s)) }

      s
    end

    def remove(_event_name, _queue_name)
      raise 'Method, remove, needs to be implemented for this subscription storage'
    end
  end
end
