require 'uri'

module RServiceBus2
  class JobTooBigError < StandardError
  end

  # Wrapper base class for Queue implementations available to the applications,
  # allowing rservicebus to instatiate and configure queue implementations at
  # startup - dependency injection.
  class MQ
    attr_reader :local_queue_name

    def self.get
      mq_string = RServiceBus2.get_value('RSBMQ', 'beanstalk://localhost')
      uri = URI.parse(mq_string)

      case uri.scheme
      when 'beanstalk'
        require 'rservicebus2/mq/beanstalk'
        mq = MQBeanstalk.new(uri)
      else
        abort("Scheme, #{uri.scheme}, not recognised when configuring mq,
          #{string}")
      end

      mq
    end

    # Resources are attached, and are be specified using the URI syntax
    # @param [URI] uri the type and location of queue,
    #  eg beanstalk://127.0.0.1/foo
    # @param [Integer] timeout the amount of time to wait for a msg to arrive
    def initialize(uri)
      if uri.is_a? URI
        @uri = uri
      else
        puts 'uri must be a valid URI'
        abort
      end

      if uri.path == '' || uri.path == '/'
        @local_queue_name = RServiceBus2.get_value('APPNAME', 'RServiceBus')
      else
        @local_queue_name = uri.path
        @local_queue_name[0] = ''
      end

      if @local_queue_name == ''
        puts "@local_queue_name: #{@local_queue_name}"
        puts 'Queue name must be supplied '
        puts "*** uri, #{uri}, needs to contain a queue name"
        puts '*** the structure is scheme://host[:port]/queuename'
        abort
      end

      @timeout = RServiceBus2.get_value('QUEUE_TIMEOUT', '5').to_i
      connect(uri.host, uri.port)
      subscribe(@local_queue_name)
    end

    # Connect to the broker
    # @param [String] host machine runnig the mq
    # @param [String] port port the mq is running on
    def connect(_host, _port)
      fail 'Method, connect, needs to be implemented'
    end

    # Connect to the receiving queue
    # @param [String] queuename name of the receiving queue
    def subscribe(_queuename)
      fail 'Method, subscribe, needs to be implemented'
    end

    # Get next msg from queue
    def pop
      fail 'Method, pop, needs to be implemented'
    end

    # "Commit" the pop
    def ack
      fail 'Method, ack, needs to be implemented'
    end

    # At least called in the Host rescue block, to ensure all network links are
    #  healthy
    # @param [String] queue_name name of the queue to which the msg should be sent
    # @param [String] msg msg to be sent
    def send(queue_name, msg)
      begin
        @connection.close
      rescue
        puts 'AppResource. An error was raised while closing connection to, ' + @uri.to_s
      end

end

end
end
