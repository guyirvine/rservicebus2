module RServiceBus
  # Saga Storage
  class SagaStorage
    def self.get(uri)
      case uri.scheme
      when 'dir'
        require 'rservicebus/saga_storage/dir'
        return SagaStorageDir.new(uri)
      when 'inmem'
        require 'rservicebus/saga_storage/inmemory'
        return SagaStorageInMemory.new(uri)
      else
        abort("Scheme, #{uri.scheme}, not recognised when configuring
          SagaStorage, #{uri}")
      end
    end
  end
end
