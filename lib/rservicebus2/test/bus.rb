module RServiceBus2
  # Test Bus
  class TestBus
    attr_accessor :publish_list, :send_list, :reply_list, :log_list, :saga_data

    def initialize
      @publish_list = []
      @send_list = []
      @reply_list = []
      @log_list = []
    end

    def publish(msg)
      @publish_list << msg
    end

    def send(msg)
      @send_list << msg
    end

    def reply(msg)
      @reply_list << msg
    end

    def log(string, verbose = false)
      item = {}
      item['string'] = string
      item['verbose'] = verbose
      @log_list << item
    end
  end
end
