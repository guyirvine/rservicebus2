
module RServiceBus2
  # Send At Storage
  class SendAtStorage
    def self.get(uri)
      case uri.scheme
      when 'file'
        require 'rservicebus2/sendat_storage/file'
        return SendAtStorageFile.new(uri)
      when 'inmem'
        require 'rservicebus2/sendat_storage/inmemory'
        return SendAtStorageInMemory.new(uri)
      else
        abort("Scheme, #{uri.scheme}, not recognised when configuring
          SendAtStorage, #{uri}")
      end
    end

  end
end
