module RServiceBus2
  # StateStorage InMemory
  class StateStorageInMemory
    def initialize(_uri)
      @hash = {}
    end

    def begin
      @list = []
    end

    def get(handler)
      hash = @hash[handler.class.name]
      @list << Hash['name', handler.class.name, 'hash', hash]

      hash
    end

    def commit
      @list.each do |e|
        @hash[e['name']] = e['hash']
      end
    end
  end
end
