module RServiceBus2
  # App Resource File
  class AppResourceFile < AppResource
    def connect(uri)
      File.new(uri.path)
    end
  end
end
