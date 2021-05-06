# frozen_string_literal: true

module RServiceBus2
  # Coordinate Transactions across resources, handlers, and Sagas
  class ResourceManager
    # Constructor
    def initialize(state_manager, saga_storage)
      @app_resources = {}
      @current_resources = {}
      @state_manager = state_manager
      @saga_storage = saga_storage
    end

    def add(name, res)
      @app_resources[name] = res
    end

    def all
      @app_resources
    end

    def begin
      @current_resources = {}
      @state_manager.begin
      @saga_storage.begin
    end

    def get(name)
      if @current_resources[name].nil?
        r = @app_resources[name]
        r._connect
        r.begin
        RServiceBus2.rlog "Preparing resource: #{name}. Begin"
      end
      @current_resources[name] = @app_resources[name]
      @app_resources[name]
    end

    def commit(msg_name)
      @state_manager.commit
      @saga_storage.commit
      RServiceBus2.rlog "HandlerManager.commitResourcesUsedToProcessMsg, #{msg_name}"
      @current_resources.each do |_k, v|
        RServiceBus2.rlog "Commit resource, #{v.class.name}"
        v.commit
        v.finished
      end
    end

    def rollback(msg_name)
      @saga_storage.rollback
      RServiceBus2.rlog "HandlerManager.rollbackResourcesUsedToProcessMsg, #{msg_name}"
      @current_resources.each do |_k, v|
        RServiceBus2.rlog "Rollback resource, #{v.class.name}"
        v.rollback
        v.finished
      rescue StandardError => e
        puts "Caught nested exception rolling back, #{v.class.name}, for msg,
          #{msg_name}"
        puts "****\n#{e.message}\n#{e.backtrace}\n'****"
      end
    end
  end
end
