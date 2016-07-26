module RServiceBus2
  # A means for a stand-alone process to interact with the bus, without
  #  being a full rservicebus application
  class MockHost
    def log(_string, _ver = false)
    end
  end
end
