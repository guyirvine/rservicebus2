module RServiceBus
  # Sags Base Class
  class SagaBase
    attr_accessor :data

    def initialize
      @finished = false
    end

    def send_timeout(_msg, _milliseconds)
    end

    def finish
      @data.finished = true
    end
  end
end
