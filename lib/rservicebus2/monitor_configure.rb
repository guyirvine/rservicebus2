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

    # Assigns appropriate resources to writable attributes in the handler that
    #  match keys in the resource hash
    # @param [RServiceBus2::Handler] handler
    def set_app_resources(monitor)
      RServiceBus2.rlog "Checking app resources for: #{monitor.class.name}"
      RServiceBus2.rlog "If your attribute is not getting set, check that it is
        in the 'attr_accessor' list"
      @resource_manager.get_all.each do |k, v|
        next unless monitor.class.method_defined?(k)

        monitor.instance_variable_set("@#{k}", v.get_resource)
        @resource_list[monitor.class.name] = [] if
          @resource_list[monitor.class.name].nil?
        @resource_list[monitor.class.name] << v
        @host.log "App resource attribute, #{k}, set for: " +
          monitor.class.name
      end
      self
    end

    def get_monitors(env)
      monitors = []

      env.each do |k, v|
        if v.is_a?(String) && k.start_with?('RSBOB_')
          uri = URI.parse(v)
          name = k.sub('RSBOB_', '')
          monitor = nil
          case uri.scheme
          when 'dir'
            require 'rservicebus2/monitor/dir'
            monitor = MonitorDir.new(@host, name, uri)
          when 'awss3'
            require 'rservicebus2/monitor/awss3'
            monitor = MonitorAWSS3.new(@host, name, uri)
          when 'dirnotifier'
            require 'rservicebus2/monitor/dirnotifier'
            monitor = MonitorDirNotifier.new(@host, name, uri)
          else
            abort("Scheme, #{uri.scheme}, not recognised when configuring
              Monitor, #{k}=#{v}")
          end
          set_app_resources(monitor)
          monitors << monitor
        end
      end
      monitors
    end
  end
end
