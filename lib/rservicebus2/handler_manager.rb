# frozen_string_literal: true

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
    def conditionally_set_bus_attribute(handler)
      if defined?(handler.bus)
        handler.bus = @host
        RServiceBus2.log "Bus attribute set for: #{handler.class.name}"
      end

      self
    end

    # setStateAttributeIfRequested
    #
    # @param [RServiceBus2::Handler] handler
    def conditionally_set_state_attribute(handler)
      if defined?(handler.state)
        handler.state = @state_manager.get(handler)
        RServiceBus2.log "Bus attribute set for: #{handler.class.name}"
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

    # rubocop:disable Metrics/AbcSize
    def interrogate_handler_for_app_resources(handler)
      RServiceBus2.rlog "Checking app resources for: #{handler.class.name}\n" \
                        "If your attribute is not getting set, check that it is in the 'attr_accessor' list"

      @resource_list_by_handler_name[handler.class.name] = []
      @resource_manager.all.each do |k, _v|
        next unless handler.class.method_defined?(k)

        @resource_list_by_handler_name[handler.class.name] << k
        RServiceBus2.log "Resource attribute, #{k}, found for: #{handler.class.name}"
      end
    end
    # rubocop:enable Metrics/AbcSize

    def add_handler(lc_msg_name, handler)
      # Turn snake_case string to CamelCase
      msg_name = lc_msg_name.gsub(/(?<=_|^)(\w)/) { Regexp.last_match(1).upcase }.gsub(/(?:_)(\w)/, '\1')
      @handler_list[msg_name] = [] if @handler_list[msg_name].nil?
      return unless @handler_list[msg_name].index { |x| x.instance_of(handler) }.nil?

      @handler_list[msg_name] << handler
      conditionally_set_bus_attribute(handler)
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
        unless @resource_list_by_handler_name[handler.class.name].nil?
          list += @resource_list_by_handler_name[handler.class.name]
        end
      end
      list.uniq!
    end

    # rubocop:disable Metrics/AbcSize
    def conditionally_set_resources_for_handlers(msg_name)
      @handler_list[msg_name].each do |handler|
        conditionally_set_state_attribute(handler)
        next if @resource_list_by_handler_name[handler.class.name].nil?

        @resource_list_by_handler_name[handler.class.name].each do |k|
          handler.instance_variable_set("@#{k}", @resource_manager.get(k).get_resource)
          RServiceBus2.rlog "App resource attribute, #{k}, set for: #{handler.class.name}"
        end
      end
    end
    # rubocop:enable Metrics/AbcSize

    def get_handler_list_for_msg(msg_name)
      return [] if @handler_list[msg_name].nil?

      # list = get_list_of_resources_needed_to_process_msg(msg_name)
      conditionally_set_resources_for_handlers(msg_name)

      @handler_list[msg_name]
    end

    def can_msg_be_handled_locally(msg_name)
      @handler_list.key?(msg_name)
    end

    def stats
      list = []
      @handler_list.each do |_k, v|
        list << v.inspect
      end

      list
    end

    def msg_names
      @handler_list.keys
    end
  end
end
