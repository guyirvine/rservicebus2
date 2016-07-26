module RServiceBus2
  class NoHandlerFound < StandardError
  end
  class ClassNotFoundForMsg < StandardError
  end
  class NoMsgToProcess < StandardError
  end
  class PropertyNotSet < StandardError
  end

  # Host process for rservicebus
  class Host
    attr_accessor :saga_data

    # Provides a thin logging veneer
    # @param [String] string Log entry
    # @param [Boolean] ver Indicator for a verbose log entry
    def log(string, ver = false)
      RServiceBus2.log(string, ver)
    end

    # Thin veneer for Configuring external resources
    def configure_app_resource
      @resource_manager = ConfigureAppResource.new
                                              .get_resources(ENV,
                                                             self,
                                                             @state_manager,
                                                             @saga_storage)
      self
    end

    # Thin veneer for Configuring SendAt
    def configure_send_at_manager
      @send_at_manager = SendAtManager.new(self)
      self
    end

    # Thin veneer for Configuring state
    def configure_state_manager
      @state_manager = StateManager.new
      self
    end

    # Thin veneer for Configuring state
    def configure_saga_storage
      string = RServiceBus2.get_value('SAGA_URI')
      string = 'dir:///tmp' if string.nil?

      uri = URI.parse(string)
      @saga_storage = SagaStorage.get(uri)
      self
    end

    # Thin veneer for Configuring Cron
    def configure_circuit_breaker
      @circuit_breaker = CircuitBreaker.new(self)
      self
    end

    # Thin veneer for Configuring external resources
    def configure_monitors
      @monitors = ConfigureMonitor.new(self, @resource_manager).get_monitors(ENV)
      self
    end

    # Thin veneer for Configuring the Message Queue
    def connect_to_mq
      @mq = MQ.get
      self
    end

    # Subscriptions are specified by adding events to the
    # msg endpoint mapping
    def send_subscriptions
      log 'Send Subscriptions'

      @endpoint_mapping.get_subscription_endpoints.each do |event_name|
        subscribe(event_name)
      end

      self
    end

    # Load and configure Message Handlers
    def load_handlers
      log 'Load Message Handlers'
      @handler_manager = HandlerManager.new(self, @resource_manager, @state_manager)
      @handler_loader = HandlerLoader.new(self, @handler_manager)

      @config.handler_path_list.each do |path|
        @handler_loader.load_handlers_from_path(path)
      end

      self
    end

    # Load and configure Sagas
    def load_sagas
      log 'Load Sagas'
      @saga_manager = SagaManager.new(self, @resource_manager, @saga_storage)
      @saga_loader = SagaLoader.new(self, @saga_manager)

      @config.saga_path_list.each do |path|
        @saga_loader.load_sagas_from_path(path)
      end

      self
    end

    # Thin veneer for Configuring Cron
    def configure_cron_manager
      @cron_manager = CronManager.new(self, @handler_manager.get_list_of_msg_names)
      self
    end

    # Load Contracts
    def load_contracts
      log 'Load Contracts'

      @config.contract_list.each do |path|
        require path
        RServiceBus2.rlog "Loaded Contract: #{path}"
      end

      self
    end

    # For each directory given, find and load all librarys
    def load_libs
      log 'Load Libs'
      @config.lib_list.each do |path|
        $:.unshift path
      end

      self
    end

    # Load, configure and initialise Subscriptions
    def configure_subscriptions
      subscription_storage = ConfigureSubscriptionStorage.new.get(@config.app_name, @config.subscription_uri)
      @subscription_manager = SubscriptionManager.new(subscription_storage)
      self
    end

    # Initialise statistics monitor
    def configure_statistics
      @stats = StatisticManager.new( self )
      self
    end

    def initialize
      RServiceBus2.rlog "Current directory: #{Dir.pwd}"
      @config = ConfigFromEnv.new.load_host_section
                                  .load_contracts
                                  .load_handler_path_list
                                  .load_saga_path_list
                                  .load_libs
                                  .load_working_dir_list

      connect_to_mq

      @endpoint_mapping = EndpointMapping.new.configure(@mq.local_queue_name)

      self.configure_statistics
          .load_contracts
          .load_libs
          .configure_send_at_manager
          .configure_state_manager
          .configure_saga_storage
          .configure_app_resource
          .configure_circuit_breaker
          .configure_monitors
          .load_handlers
          .load_sagas
          .configure_cron_manager
          .configure_subscriptions
          .send_subscriptions

      self
    end

    # Ignition
    def run
      log 'Starting the Host'
      log "Watching, #{@mq.local_queue_name}"
      $0 = "rservicebus - #{@mq.local_queue_name}"
      unless @config.forward_received_messages_to.nil?
        log 'Forwarding all received messages to: ' + @config.forward_received_messages_to.to_s
      end
      unless @config.forward_sent_messages_to.nil?
        log 'Forwarding all sent messages to: ' + @config.forward_sent_messages_to.to_s
      end

      start_listening_to_endpoints
    end

    # Receive a msg, prep it, and handle any errors that may occur
    # - Most of this should be queue independant
    def start_listening_to_endpoints
      log 'Waiting for messages. To exit press CTRL+C'
      message_loop = true
      retries = @config.max_retries

      while message_loop
        # Popping a msg off the queue should not be in the message handler,
        #  as it affects retry
        begin
          @stats.tick
          if @circuit_breaker.broken
            sleep 0.5
            next
          end

          body = @mq.pop
          begin
            @stats.inc_total_processed
            @msg = YAML.load(body)
            case @msg.msg.class.name
            when 'RServiceBus2::MessageSubscription'
              @subscription_manager.add(@msg.msg.event_name,
                                        @msg.return_address)
            when 'RServiceBus2::MessageStatisticOutputOn'
              @stats.output = true
              log 'Turn on Stats logging'
            when 'RServiceBus2::MessageStatisticOutputOff'
              @stats.output = false
              log 'Turn off Stats logging'
            when 'RServiceBus2::MessageVerboseOutputOn'
              ENV['VERBOSE'] = 'true'
              log 'Turn on Verbose logging'
            when 'RServiceBus2::MessageVerboseOutputOff'
              ENV.delete('VERBOSE')
              log 'Turn off Verbose logging'
            else
              handle_message
              unless @config.forward_received_messages_to.nil?
                _send_already_wrapped_and_serialised(body, @config.forward_received_messages_to)
              end
            end
            @mq.ack
          rescue ClassNotFoundForMsg => e
            puts "*** Class not found for msg, #{e.message}"
            puts "*** Ensure, #{e.message}, is defined in contract.rb, most
              likely as 'Class #{e.message} end"

            @msg.add_error_msg(@mq.local_queue_name, e.message)
            serialized_object = YAML.dump(@msg)
            _send_already_wrapped_and_serialised(serialized_object,
                                                 @config.error_queue_name)
            @mq.ack
          rescue NoHandlerFound => e
            puts "*** Handler not found for msg, #{e.message}"
            puts "*** Ensure a handler named, #{e.message}, is present in the
              messagehandler directory."

            @msg.add_error_msg(@mq.local_queue_name, e.message)
            serialized_object = YAML.dump(@msg)
            _send_already_wrapped_and_serialised(serialized_object,
                                                 @config.error_queue_name)
            @mq.ack

          rescue PropertyNotSet => e
            # This has been re-rasied from a rescue in the handler
            puts "*** #{e.message}"
            # "Property, #{e.message}, not set for, #{handler.class.name}"
            property_name = e.message[10, e.message.index(',', 10) - 10]
            puts "*** Ensure the environment variable, RSB_#{property_name},
              has been set at startup."

          rescue StandardError => e
            sleep 0.5

            puts '*** Exception occurred'
            puts e.message
            puts e.backtrace
            puts '***'

            if retries > 0
              retries -= 1
              @mq.return_to_queue
            else
              @circuit_breaker.failure
              @stats.inc_total_errored
              if e.class.name == 'Beanstalk::NotConnected'
                puts 'Lost connection to beanstalkd.'
                puts '*** Start or Restart beanstalkd and try again.'
                abort
              end

              if e.class.name == 'Redis::CannotConnectError'
                puts 'Lost connection to redis.'
                puts '*** Start or Restart redis and try again.'
                abort
              end

              error_string = e.message + '. ' + e.backtrace.join('. ')
              @msg.add_error_msg(@mq.local_queue_name, error_string)
              serialized_object = YAML.dump(@msg)
              _send_already_wrapped_and_serialised(serialized_object, @config.error_queue_name)
              @mq.ack
              retries = @config.max_retries
            end
          end
        rescue SystemExit, Interrupt
          puts 'Exiting on request ...'
          message_loop = false
        rescue NoMsgToProcess => e
          # This exception is just saying there are no messages to process
          @queue_for_msgs_to_be_sent_on_complete = []
          @monitors.each(&:look)
          send_queued_msgs
          @queue_for_msgs_to_be_sent_on_complete = nil

          @queue_for_msgs_to_be_sent_on_complete = []
          @cron_manager.run
          send_queued_msgs
          @queue_for_msgs_to_be_sent_on_complete = nil

          @send_at_manager.process
          @circuit_breaker.success

        rescue StandardError => e
          if e.message == 'SIGTERM' || e.message == 'SIGINT'
            puts 'Exiting on request ...'
            message_loop = false
          else
            puts '*** This is really unexpected.'
            message_loop = false
            puts 'Message: ' + e.message
            puts e.backtrace
          end
        end
      end
    end

    # Send the current msg to the appropriate handlers
    def handle_message
      @resource_manager.begin
      msg_name = @msg.msg.class.name
      handler_list = @handler_manager.get_handler_list_for_msg(msg_name)
      RServiceBus2.rlog 'Handler found for: ' + msg_name
      begin
        @queue_for_msgs_to_be_sent_on_complete = []

        log "Started processing msg, #{msg_name}"
        handler_list.each do |handler|
          begin
            log "Handler, #{handler.class.name}, Started"
            handler.handle(@msg.msg)
            log "Handler, #{handler.class.name}, Finished"
          rescue PropertyNotSet => e
            raise PropertyNotSet.new( "Property, #{e.message}, not set for, #{handler.class.name}" )
          rescue StandardError => e
            puts "E #{e.message}"
            log 'An error occurred in Handler: ' + handler.class.name
            raise e
          end
        end

        if @saga_manager.handle(@msg) == false && handler_list.length == 0
          fail NoHandlerFound, msg_name
        end
        @resource_manager.commit(msg_name)

        send_queued_msgs
        log "Finished processing msg, #{msg_name}"

      rescue StandardError => e
        @resource_manager.rollback(msg_name)
        @queue_for_msgs_to_be_sent_on_complete = nil
        raise e
      end
    end

#######################################################################################################
# All msg sending Methods

    # Sends a msg across the bus
    # @param [String] serialized_object serialized RServiceBus2::Message
    # @param [String] queue_name endpoint to which the msg will be sent
    def _send_already_wrapped_and_serialised(serialized_object, queue_name)
      RServiceBus2.rlog 'Bus._send_already_wrapped_and_serialised'

      unless @config.forward_sent_messages_to.nil?
        @mq.send(@config.forward_sent_messages_to, serialized_object)
      end

      @mq.send(queue_name, serialized_object)
    end

    # Sends a msg across the bus
    # @param [RServiceBus2::Message] msg msg to be sent
    # @param [String] queueName endpoint to which the msg will be sent
    def _send_needs_wrapping(msg, queue_name, correlation_id)
      RServiceBus2.rlog 'Bus._send_needs_wrapping'

      r_msg = RServiceBus2::Message.new(msg, @mq.local_queue_name, correlation_id)
      if queue_name.index('@').nil?
        q = queue_name
        RServiceBus2.rlog "Sending, #{msg.class.name} to, #{queue_name}"
      else
        parts = queue_name.split('@')
        r_msg.set_remote_queue_name(parts[0])
        r_msg.set_remote_host_name(parts[1])
        q = 'transport-out'
        RServiceBus2.rlog "Sending, #{msg.class.name} to, #{queue_name}, via #{q}"
      end

      serialized_object = YAML.dump(r_msg)
      _send_already_wrapped_and_serialised(serialized_object, q)
    end

    def send_queued_msgs
      @queue_for_msgs_to_be_sent_on_complete.each do |row|
        if row['timestamp'].nil?
          _send_needs_wrapping(row['msg'], row['queue_name'], row['correlation_id'])
        else
          @send_at_manager.add(row)
        end
      end
    end

    def queue_msg_for_send_on_complete(msg, queue_name, timestamp = nil)
      correlation_id = @saga_data.nil? ? nil : @saga_data.correlation_id
      correlation_id = (!@msg.nil? && !@msg.correlation_id.nil?) ? @msg.correlation_id : correlation_id
      @queue_for_msgs_to_be_sent_on_complete << Hash['msg', msg, 'queue_name', queue_name, 'correlation_id', correlation_id, 'timestamp',timestamp ]
    end

    # Sends a msg back across the bus
    # Reply queues are specified in each msg. It works like
    # email, where the reply address can actually be anywhere
    # @param [RServiceBus2::Message] msg msg to be sent
    def reply(msg)
      RServiceBus2.rlog 'Reply with: ' + msg.class.name + ' To: ' + @msg.return_address
      @stats.inc_total_reply

      queue_msg_for_send_on_complete(msg, @msg.return_address)
    end

    def get_endpoint_for_msg(msg_name)
      queue_name = @endpoint_mapping.get(msg_name)
      return queue_name unless queue_name.nil?

      return @mq.local_queue_name if @handler_manager.can_msg_be_handled_locally(msg_name)

      log 'No end point mapping found for: ' + msg_name
      log '**** Check environment variable MessageEndpointMappings contains an entry named : ' + msg_name
      raise 'No end point mapping found for: ' + msg_name
    end


    # Send a msg across the bus
    # msg destination is specified at the infrastructure level
    # @param [RServiceBus2::Message] msg msg to be sent
    def send( msg, timestamp=nil )
      RServiceBus2.rlog 'Bus.Send'
      @stats.inc_total_sent

      msg_name = msg.class.name
      queue_name = self.get_endpoint_for_msg(msg_name)
      queue_msg_for_send_on_complete(msg, queue_name, timestamp)
    end

    # Sends an event to all subscribers across the bus
    # @param [RServiceBus2::Message] msg msg to be sent
    def publish(msg)
      RServiceBus2.rlog 'Bus.Publish'
      @stats.inc_total_published

      subscriptions = @subscription_manager.get(msg.class.name)
      subscriptions.each do |subscriber|
        queue_msg_for_send_on_complete(msg, subscriber)
      end
    end

    # Sends a subscription request across the Bus
    # @param [String] eventName event to be subscribes to
    def subscribe(event_name)
      RServiceBus2.rlog 'Bus.Subscribe: ' + event_name

      queue_name = get_endpoint_for_msg(event_name)
      subscription = MessageSubscription.new(event_name)

      _send_needs_wrapping(subscription, queue_name, nil)
    end
  end
end
