module RServiceBus
  # Saga Storage In Memory
  class SagaStorageInMemory
    def initialize(_uri)
    end

    # Start
    def begin
      @hash = {}
      @deleted = {}
    end

    # Set
    def set(data)
      @hash[data.correlation_id] = data
    end

    # Get
    def get(correlation_id)
      @hash[correlation_id]
    end

    # Finish
    def commit
      @deleted.each do |correlation_id|
        @hash.delete(correlation_id)
      end
    end

    def delete(correlation_id)
      @deleted << correlation_id
    end

    def rollback
    end
  end
end
