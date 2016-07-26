module RServiceBus2
  # State Storage
  class StateStorage
    def self.get(uri)
      case uri.scheme
      when 'dir'
        require 'rservicebus2/state_storage/dir.rb'
        return StateStorageDir.new(uri)
      when 'inmem'
        require 'rservicebus2/state_storage/inmemory.rb'
        return StateStorageInMemory.new(uri)
      else
        abort("Scheme, #{uri.scheme}, not recognised when configuring
          StateStorage, #{uri}")
      end
    end
  end
end
