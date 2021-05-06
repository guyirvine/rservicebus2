module RServiceBus2
  # Given a directory, this class is responsible for finding
  #  msgnames,
  #  handlernames, and
  #  loading handlers
  class HandlerManager
    # Constructor
    #
    # @param [RServiceBus2::Host] host instance
    # @param [Hash] app_resources As hash[k,v] where k is the name of a resource, and v is the resource
    def initialize(host, resource_manager, state_manager)
      @host = host
      @resource_manager = resource_manager
      @state_manager = state_manager

      @handler_list = {}
      @resource_list_by_handler_name = {}
    end

    # setBusAttributeIfRequested
    #
    # @param [RServiceBus2::Handler] handler
    def set_bus_attribute_if_requested(handler)
      if defined?(handler.bus)
        handler.bus = @host
        RServiceBus2.log 'Bus attribute set for: ' + handler.class.name
      end

      self
    end

    # setStateAttributeIfRequested
    #
    # @param [RServiceBus2::Handler] handler
    def set_state_attribute_if_requested(handler)
      if defined?(handler.state)
        handler.state = @state_manager.get(handler)
        RServiceBus2.log 'Bus attribute set for: ' + handler.class.name
      end

      self
    end

    # checkIfStateAttributeRequested
    #
    # @param [RServiceBus2::Handler] handler
    def check_if_state_attribute_requested(handler)
      @state_manager.required if defined?(handler.state)

      self
    end

    def interrogate_handler_for_app_resources(handler)
      RServiceBus2.rlog "Checking app resources for: #{handler.class.name}"
      RServiceBus2.rlog "If your attribute is not getting set, check that it is in the 'attr_accessor' list"

      @resource_list_by_handler_name[handler.class.name] = []
      @resource_manager.all.each do |k, v|
        next unless handler.class.method_defined?(k)

        @resource_list_by_handler_name[handler.class.name] << k
        RServiceBus2.log "Resource attribute, #{k}, found for: " +
          handler.class.name
      end

      self
    end

    def add_handler(lc_msg_name, handler)
      msg_name = lc_msg_name.gsub(/(?<=_|^)(\w)/){$1.upcase}.gsub(/(?:_)(\w)/,'\1') # Turn snake_case string to CamelCase
      @handler_list[msg_name] = [] if @handler_list[msg_name].nil?
      return unless @handler_list[msg_name].index{ |x| x.class.name == handler.class.name }.nil?

      @handler_list[msg_name] << handler
      set_bus_attribute_if_requested(handler)
      check_if_state_attribute_requested(handler)
      interrogate_handler_for_app_resources(handler)
    end

    # As named
    #
    # @param [String] msgName
    # @param [Array] appResources A list of appResource
    def get_list_of_resources_needed_to_process_msg(msg_name)
      return [] if @handler_list[msg_name].nil?

      list = []
      @handler_list[msg_name].each do |handler|
        list = list + @resource_list_by_handler_name[handler.class.name] unless @resource_list_by_handler_name[handler.class.name].nil?
      end
      list.uniq!
    end

    def set_resources_for_handlers_needed_to_process_msg(msg_name)
      @handler_list[msg_name].each do |handler|
        set_state_attribute_if_requested(handler)

        next if @resource_list_by_handler_name[handler.class.name].nil?
        @resource_list_by_handler_name[handler.class.name].each do |k|
          handler.instance_variable_set("@#{k}", @resource_manager.get(k).get_resource)
          RServiceBus2.rlog "App resource attribute, #{k}, set for: " + handler.class.name
        end
      end
    end

    def get_handler_list_for_msg(msg_name)
      return [] if @handler_list[msg_name].nil?

      list = get_list_of_resources_needed_to_process_msg(msg_name)
      set_resources_for_handlers_needed_to_process_msg(msg_name)

      @handler_list[msg_name]
    end

    def can_msg_be_handled_locally(msg_name)
      @handler_list.key?(msg_name)
    end

    def get_stats
      list = []
      @handler_list.each do |k, v|
        list << v.inspect
      end

      list
    end

    def get_list_of_msg_names
      @handler_list.keys
    end
  end
end
