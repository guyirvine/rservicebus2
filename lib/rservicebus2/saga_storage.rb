# frozen_string_literal: true

module RServiceBus2
  # Saga Storage
  class SagaStorage
    def self.get(uri)
      case uri.scheme
      when 'dir'
        require 'rservicebus2/saga_storage/dir'
        SagaStorageDir.new(uri)
      when 'inmem'
        require 'rservicebus2/saga_storage/inmemory'
        SagaStorageInMemory.new(uri)
      else
        abort("Scheme, #{uri.scheme}, not recognised when configuring SagaStorage, #{uri}")
      end
    end
  end
end
