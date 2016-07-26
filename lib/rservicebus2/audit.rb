module RServiceBus2
  # Audit Class
  class Audit
    def initialize(mq)
      @mq = mq
      audit_queue_name = RServiceBus.get_value('AUDIT_QUEUE_NAME')
      if audit_queue_name.nil?
        @sent_messages_to = RServiceBus.get_value('sent_messages_to')
        @received_messages_to = RServiceBus.get_value('received_messages_to')
      else
        @sent_messages_to = audit_queue_name
        @received_messages_to = audit_queue_name
      end
    end

    def audit_to_queue(obj)
      @mq.send_msg(obj, @sent_messages_to)
    end

    def audit_outgoing(obj)
      audit_to_queue(obj) unless @sent_messages_to.nil?
    end

    def audit_incoming(obj)
      audit_to_queue(obj) unless @received_messages_to.nil?
    end
  end
end
