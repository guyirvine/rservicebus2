
module RServiceBus
  # Send At Storage
  class SendAtStorage
    def self.get(uri)
      case uri.scheme
      when 'file'
        require 'rservicebus/sendat_storage/file'
        return SendAtStorageFile.new(uri)
      when 'inmem'
        require 'rservicebus/sendat_storage/inmemory'
        return SendAtStorageInMemory.new(uri)
      else
        abort("Scheme, #{uri.scheme}, not recognised when configuring
          SendAtStorage, #{uri}")
      end
    end

  end
end
