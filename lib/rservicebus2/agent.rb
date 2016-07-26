module RServiceBus2
  class QueueNotFoundForMsg < StandardError
  end

  # A means for a stand-alone process to interact with the bus, without being
  # a full rservicebus application
  class Agent
    def get_agent(uri)
      ENV['RSBMQ'] = uri.to_s

      RServiceBus2.rlog '*** Agent.getAgent has been deprecated. Set the
                      environment variable, RSBMQ, and simply create the class'
      Agent.new
    end

    def initialize
      @mq = MQ.get
    end

    # Put a msg on the bus
    #
    # @param [Object] messageObj The msg to be sent
    # @param [String] queueName the name of the queue to be send the msg to
    # @param [String] returnAddress the name of a queue to send replies to
    def send_msg(message_obj, queue_name, return_address = nil)
      fail QueueNotFoundForMsg, message_obj.class.name if queue_name.nil?

      msg = RServiceBus::Message.new(message_obj, return_address)
      if queue_name.index('@').nil?
        q = queue_name
      else
        parts = queueName.split('@')
        msg.set_remote_queue_name(parts[0])
        msg.set_remote_host_name(parts[1])
        q = 'transport-out'
      end

      serialized_object = YAML.dump(msg)

      @mq.send(q, serialized_object)
    end

    # Gives an agent the means to receive a reply
    #
    # @param [String] queueName the name of the queue to monitor for messages
    def check_for_reply(queue_name)
      @mq.subscribe(queue_name)
      body = @mq.pop
      @msg = YAML.load(body)
      @mq.ack
      @msg.msg
    end
  end
end
