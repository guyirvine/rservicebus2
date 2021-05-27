# frozen_string_literal: true

require 'uri'

module RServiceBus2
  # Wrapper base class for resources used by applications, allowing rservicebus
  # to configure the resource - dependency injection.
  class AppResource
    attr_reader :connection

    # The method which actually connects to the resource.
    def connect(_uri)
      raise 'Method, connect, needs to be implemented for resource'
    end

    def _connect
      @connection = connect(@uri)
      RServiceBus2.rlog "#{self.class.name}. Connected to, #{@uri}"
    end

    def resource
      @connection
    end

    # Resources are attached, and can be specified using the URI syntax.
    # @param [String] uri a location for the resource to which we will attach,
    #  eg redis://127.0.0.1/foo
    def initialize(host, uri)
      @host = host
      @uri = uri
      # Do a connect / disconnect loop on startup to validate the connection
      _connect
      finished
    end

    # Allow for cleanup, outside of transaction semantics
    def finished
      @connection.close
    end

    # At least called in the Host rescue block, to ensure all network links are
    #  healthy
    def reconnect
      begin
        finished
      rescue StandardError => e
        puts '** AppResource. An error was raised while closing connection
              to, ' + @uri
        puts "Message: #{e.message}"
        puts e.backtrace
      end
      _connect
    end

    # Transaction Semantics
    def begin
      RServiceBus2.rlog "#{self.class.name}. Default transaction.begin called"
    end

    # Transaction Semantics
    def commit
      RServiceBus2.rlog "#{self.class.name}. Default transaction.commit called"
    end

    # Transaction Semantics
    def rollback
      RServiceBus2.rlog "#{self.class.name}. Default transaction.rollback called"
    end
  end
end
