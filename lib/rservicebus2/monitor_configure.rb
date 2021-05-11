# frozen_string_literal: true

require 'rservicebus2/monitor'
require 'rservicebus2/monitor/message'

module RServiceBus2
  # Configure Monitors for an rservicebus host
  class ConfigureMonitor
    # Constructor
    # @param [RServiceBus2::Host] host instance
    # @param [Hash] resourceManager As hash[k,v] where k is the name of a
    #  resource, and v is the resource
    def initialize(host, resource_manager)
      @host = host
      @resource_manager = resource_manager

      @handler_list = {}
      @resource_list = {}
    end

    def conditionally_set_app_resource(monitor, key, val)
      monitor.instance_variable_set("@#{key}", val.resource)
      @resource_list[monitor.class.name] = [] if @resource_list[monitor.class.name].nil?
      @resource_list[monitor.class.name] << val
      @host.log "App resource attribute, #{key}, set for: #{monitor.class.name}"
    end

    # Assigns appropriate resources to writable attributes in the handler that
    #  match keys in the resource hash
    # @param [RServiceBus2::Handler] handler
    def conditionally_set_app_resources(monitor)
      RServiceBus2.rlog "Checking app resources for: #{monitor.class.name}"
      RServiceBus2.rlog "If your attribute is not getting set, check that it is in the 'attr_accessor' list"
      @resource_manager.all.each do |k, v|
        next unless monitor.class.method_defined?(k)

        conditionally_set_app_resource(monitor, k, v)
      end
      self
    end

    # rubocop:disable Metrics/MethodLength
    def load_monitor(key, val)
      name = key.sub('RSBOB_', '')
      uri = URI.parse(val)
      monitor = nil
      case uri.scheme
      when 'dir'
        require 'rservicebus2/monitor/dir'
        monitor = MonitorDir.new(@host, name, uri)
      when 'awss3'
        require 'rservicebus2/monitor/awss3'
        monitor = MonitorAWSS3.new(@host, name, uri)
      when 'awssqs'
        require 'rservicebus2/monitor/awssqs'
        monitor = MonitorAWSSQS.new(@host, name, uri)
      when 'dirnotifier'
        require 'rservicebus2/monitor/dirnotifier'
        monitor = MonitorDirNotifier.new(@host, name, uri)
      else
        abort("Scheme, #{uri.scheme}, not recognised when configuring
          Monitor, #{key}=#{val}")
      end
      monitor
    end
    # rubocop:enable Metrics/MethodLength

    def monitors(env)
      list = []

      env.each do |k, v|
        next unless v.is_a?(String) && k.start_with?('RSBOB_')

        monitor = load_monitor(k, v)
        conditionally_set_app_resources(monitor)
        list << monitor
      end
      list
    end
  end
end
