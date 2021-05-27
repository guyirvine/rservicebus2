# frozen_string_literal: true

require 'redis'
require 'rservicebus2/mq'

module RServiceBus2
  # Redis client implementation.
  class MQRedis < MQ
    # Connect to the broker
    def connect(host, port)
      port ||= 6379
      string = "#{host}:#{port}"

      @redis = Redis.new(host: host, port: port)
    rescue StandardError => e
      puts e.message
      puts 'Error connecting to Redis for mq'
      puts "Host string, #{string}"
      abort
    end

    # Connect to the queue
    def subscribe(queuename)
      @queuename = queuename
    end

    # Get next msg from queue
    def pop
      if @redis.llen(@queuename).zero?
        sleep @timeout
        raise NoMsgToProcess
      end

      @redis.lindex @queuename, 0
    end

    # "Commit" queue
    def ack
      @redis.lpop @queuename
    end

    # At least called in the Host rescue block, to ensure all network links are healthy
    def send(queue_name, msg)
      @redis.rpush queue_name, msg
    end
  end
end
