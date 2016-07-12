module RServiceBus
  # Saga Manager
  class SagaManager
    def initialize(host, resource_manager, saga_storage)
      @handler = {}
      @start_with = {}
      @saga = {}
      @host = host

      @resource_manager = resource_manager
      @resource_list_by_saga_name = {}
      @saga_storage = saga_storage
    end

    def get_methods_by_prefix(saga, prefix)
      list = []
      saga.instance_methods.each do |name|
        list.push name.to_s.sub(prefix, '') if
          name.to_s.slice(0, prefix.length) == prefix
      end

      list
    end

    def get_start_with_method_names(saga)
      get_methods_by_prefix(saga, 'StartWith_')
    end

    # setBusAttributeIfRequested
    # @param [RServiceBus::Saga] saga
    def set_bus_attribute_if_requested(saga)
      if defined?(saga.bus)
        saga.bus = @host
        RServiceBus.log 'Bus attribute set for: ' + saga.class.name
      end

      self
    end

    def interrogateSagaForAppResources(saga)
      RServiceBus.rlog "Checking app resources for: #{saga.class.name}"
      RServiceBus.rlog "If your attribute is not getting set, check that it
        is in the 'attr_accessor' list"

      @resource_list_by_saga_name[saga.class.name] = []
      @resource_manager.get_all.each do |k, v|
        if saga.class.method_defined?(k)
          @resource_list_by_saga_name[saga.class.name] << k
          RServiceBus.log "Resource attribute, #{k}, found for: " +
            saga.class.name
        end
      end

      self
    end

    def register_saga(saga)
      s = saga.new
      set_bus_attribute_if_requested(s)

      get_start_with_method_names(saga).each do |msg_name|
        @start_with[msg_name] = [] if @start_with[msg_name].nil?
        @start_with[msg_name] << s

        RServiceBus.log "Registered, #{saga.name}, to StartWith, #{msg_name}"
      end

      @saga[saga.name] = s

      interrogate_saga_for_app_resources(s)
    end


    def prep_saga(saga)
      return if @resource_list_by_saga_name[saga.class.name].nil?

      @resource_list_by_saga_name[saga.class.name].each do |k, v|
        saga.instance_variable_set("@#{k}", @resource_manager.get(k).get_resource)
        RServiceBus.rlog "App resource attribute, #{k}, set for: " + saga.class.name
      end
    end

    def handle(rmsg)
      @resources_used = {}
      handled = false
      msg = rmsg.msg

      RServiceBus.log "SagaManager, started processing, #{msg.class.name}", true
      unless @start_with[msg.class.name].nil?
        @start_with[msg.class.name].each do |saga|
          data = Saga_Data.new(saga)
          @saga_storage.set(data)

          method_name = "StartWith_#{msg.class.name}"
          process_msg(saga, data, method_name, msg)

          handled = true
        end
      end
      return handled if handled == true

      return false if rmsg.correlation_id.nil?
      data = @saga_storage.get(rmsg.correlation_id)
      return handled if data.nil?
      method_name = "handle_#{msg.class.name}"
      saga = @saga[data.saga_class_name]
      process_msg(saga, data, method_name, msg)

      return true
    end

    def process_msg(saga, data, methodName, msg)
      @host.saga_data = data
      saga.data = data
      prep_saga(saga)

      if saga.class.method_defined?(method_name)
        saga.send method_name, msg
      end

      if data.finished == true
        @saga_storage.delete data.correlation_id
      end

      @host.saga_data = nil
    end
  end
end
