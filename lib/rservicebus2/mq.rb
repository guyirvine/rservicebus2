# frozen_string_literal: true

require 'uri'

module RServiceBus2
  class JobTooBigError < StandardError
  end

  # Wrapper base class for Queue implementations available to the applications,
  # allowing rservicebus to instatiate and configure queue implementations at
  # startup - dependency injection.
  class MQ
    attr_reader :local_queue_name

    # rubocop:disable Metrics/MethodLength
    def self.get
      mq_string = RServiceBus2.get_value('RSBMQ', 'beanstalk://localhost')
      uri = URI.parse(mq_string)

      case uri.scheme
      when 'beanstalk'
        require 'rservicebus2/mq/beanstalk'
        mq = MQBeanstalk.new(uri)
      when 'file'
        require 'rservicebus2/mq/file'
        mq = MQFile.new(uri)
      when 'redis'
        require 'rservicebus2/mq/redis'
        mq = MQRedis.new(uri)
      when 'aws'
        require 'rservicebus2/mq/aws'
        mq = MQAWS.new(uri)
      else
        abort("Scheme, #{uri.scheme}, not recognised when configuring mq,
          #{string}")
      end

      mq
    end
    # rubocop:enable Metrics/MethodLength

    # Resources are attached, and are be specified using the URI syntax
    # @param [URI] uri the type and location of queue,
    #  eg beanstalk://127.0.0.1/foo
    # @param [Integer] timeout the amount of time to wait for a msg to arrive

    # rubocop:disable Metrics/MethodLength
    def initialize(uri)
      abort 'Paramter to mq must be a valid URI' unless uri.is_a? URI

      @uri = uri
      @local_queue_name = uri.path
      @local_queue_name[0] = '' if @local_queue_name[0] == '/'
      @local_queue_name = RServiceBus2.get_value('APPNAME', 'RServiceBus') if @local_queue_name == ''

      if @local_queue_name == ''
        puts 'Queue name must be supplied ' \
             "*** uri, #{uri}, needs to contain a queue name" \
             '*** the structure is scheme://host[:port]/queuename'
        abort
      end

      @timeout = RServiceBus2.get_value('QUEUE_TIMEOUT', '5').to_i
      connect(uri.host, uri.port)
      subscribe(@local_queue_name)
    end
    # rubocop:enable Metrics/MethodLength

    # Connect to the broker
    # @param [String] host machine runnig the mq
    # @param [String] port port the mq is running on
    def connect(_host, _port)
      raise 'Method, connect, needs to be implemented'
    end

    # Connect to the receiving queue
    # @param [String] queuename name of the receiving queue
    def subscribe(_queuename)
      raise 'Method, subscribe, needs to be implemented'
    end

    # Get next msg from queue
    def pop
      raise 'Method, pop, needs to be implemented'
    end

    # "Commit" the pop
    def ack
      raise 'Method, ack, needs to be implemented'
    end

    # At least called in the Host rescue block, to ensure all network links are
    #  healthy
    # @param [String] queue_name name of the queue to which the msg should be sent
    # @param [String] msg msg to be sent
    def send(_queue_name, _msg)
      @connection.close
    rescue StandardError => e
      puts "AppResource. An error was raised while closing connection to, #{@uri}"
      puts "Error: #{e.message}"
      puts "Backtrace: #{e.backtrace}"
    end
  end
end
