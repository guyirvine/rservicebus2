module RServiceBus2
  # Saga Data
  class SagaData
    attr_reader :correlation_id, :saga_class_name
    attr_accessor :finished

    def initialize(saga)
      @createdat = DateTime.now
      @correlation_id = UUIDTools::UUID.random_create
      @saga_class_name = saga.class.name
      @finished = false

      @hash = {}
    end

    def method_missing(name, *args, &block)
      @hash.send(name, *args, &block)
    end
  end
end
