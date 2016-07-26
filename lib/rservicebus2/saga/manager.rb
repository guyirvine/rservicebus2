module RServiceBus2
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
      d_prefix = prefix.downcase
      saga.instance_methods.each do |name|
        d_name = name.downcase
        list.push d_name.to_s.sub(d_prefix, '') if d_name.to_s.slice(0, d_prefix.length) == d_prefix
      end

      list.uniq # This takes care of a very rare uppercase / lowercase issue
    end

    def get_start_with_method_names(saga)
      get_methods_by_prefix(saga, 'startwith_')
    end

    # setBusAttributeIfRequested
    # @param [RServiceBus::Saga] saga
    def set_bus_attribute_if_requested(saga)
      if defined?(saga.bus)
        saga.bus = @host
        RServiceBus2.log 'Bus attribute set for: ' + saga.class.name
      end

      self
    end

    def interrogate_saga_for_app_resources(saga)
      RServiceBus2.rlog "Checking app resources for: #{saga.class.name}"
      RServiceBus2.rlog "If your attribute is not getting set, check that it
        is in the 'attr_accessor' list"

      @resource_list_by_saga_name[saga.class.name] = []
      @resource_manager.get_all.each do |k, v|
        if saga.class.method_defined?(k)
          @resource_list_by_saga_name[saga.class.name] << k
          RServiceBus2.log "Resource attribute, #{k}, found for: " +
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

        RServiceBus2.log "Registered, #{saga.name}, to startwith, #{msg_name}", true
      end

      @saga[saga.name] = s

      interrogate_saga_for_app_resources(s)
    end


    def prep_saga(saga)
      return if @resource_list_by_saga_name[saga.class.name].nil?

      @resource_list_by_saga_name[saga.class.name].each do |k, v|
        saga.instance_variable_set("@#{k}", @resource_manager.get(k).get_resource)
        RServiceBus2.rlog "App resource attribute, #{k}, set for: " + saga.class.name
      end
    end

    def handle(rmsg)
      @resources_used = {}
      handled = false
      msg = rmsg.msg
      msg_class_name = msg.class.name.downcase

      RServiceBus2.log "SagaManager, started processing, #{msg_class_name}", true
      unless @start_with[msg_class_name].nil?
        @start_with[msg_class_name].each do |saga|
          data = SagaData.new(saga)
          @saga_storage.set(data)

          method_name = "startwith_#{msg_class_name}"
          process_msg(saga, data, method_name, msg)

          handled = true
        end
      end
      return handled if handled == true

      return false if rmsg.correlation_id.nil?
      data = @saga_storage.get(rmsg.correlation_id)
      return handled if data.nil?
      method_name = "handle_#{msg_class_name}"
      saga = @saga[data.saga_class_name]
      process_msg(saga, data, method_name, msg)

      true
    end

    def process_msg(saga, data, method_name, msg)
      @host.saga_data = data
      saga.data = data
      prep_saga(saga)

      saga.send(method_name, msg) if saga.class.method_defined?(method_name)

      @saga_storage.delete(data.correlation_id) if data.finished == true

      @host.saga_data = nil
    end
  end
end
