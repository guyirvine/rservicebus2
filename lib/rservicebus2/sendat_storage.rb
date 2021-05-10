# frozen_string_literal: true

module RServiceBus2
  # Send At Storage
  class SendAtStorage
    # rubocop:disable Metrics/MethodLength
    def self.get(uri)
      case uri.scheme
      when 'file'
        require 'rservicebus2/sendat_storage/file'
        SendAtStorageFile.new(uri)
      when 'inmem'
        require 'rservicebus2/sendat_storage/inmemory'
        SendAtStorageInMemory.new(uri)
      else
        abort("Scheme, #{uri.scheme}, not recognised when configuring
          SendAtStorage, #{uri}")
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
