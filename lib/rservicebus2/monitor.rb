# frozen_string_literal: true

module RServiceBus2
  # Monitor
  class Monitor
    attr_accessor :bus

    # The method which actually connects to the resource.
    def connect(_uri)
      raise 'Method, connect, needs to be implemented for resource'
    end

    # The method which actually connects to the resource.
    def look
      raise 'Method, Look, needs to be implemented for the Monitor'
    end

    def _connect
      @connection = connect(@uri)
      @bus.log "#{self.class.name}. Connected to, #{@uri}" if
        ENV['QUIET'].nil?
    end

    # Resources are attached resources, and can be specified using the URI
    # syntax.
    # @param [String] uri a location for the resource to which we will attach,
    #  eg redis://127.0.0.1/foo
    def initialize(bus, name, uri)
      @bus = bus
      new_anonymous_class = Class.new(MonitorMessage)
      Object.const_set(name, new_anonymous_class)
      @msg_type = Object.const_get(name)

      @uri = uri
      _connect
    end

    # A notification that allows cleanup
    def finished
      RServiceBus2.rlog "#{self.class.name}. Default Finished"
    end

    # At least called in the Host rescue block, to ensure all network links
    #  are healthy
    def reconnect
      begin
        finished
      rescue StandardError => e
        puts "** Monitor. An error was raised while closing connection to, #{@uri}"
        puts "Message: #{e.message}"
        puts e.backtrace
      end

      _connect
    end

    def send(payload, uri)
      msg = @msg_type.new(payload, uri)

      @bus.send(msg)
    end
  end
end
