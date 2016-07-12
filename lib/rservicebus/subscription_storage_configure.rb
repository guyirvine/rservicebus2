require 'uri'
module RServiceBus
  # Configure SubscriptionStorage for an rservicebus host
  class ConfigureSubscriptionStorage
    def get(app_name, uri_string)
      uri = URI.parse(uri_string)

      case uri.scheme
      when 'file'
        require 'rservicebus/subscription_storage/file'
        s = SubscriptionStorageFile.new(app_name, uri)
      else
        abort("Scheme, #{uri.scheme}, not recognised when configuring
          subscription storage, #{uri_string}")
      end
      s
    end
  end
end
