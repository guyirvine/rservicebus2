module RServiceBus
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

    def get_all
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
        RServiceBus.rlog "Preparing resource: #{name}. Begin"
      end
      @current_resources[name] = @app_resources[name]
      @app_resources[name]
    end

    def commit(msg_name)
      @state_manager.commit
      @saga_storage.commit
      RServiceBus.rlog "HandlerManager.commitResourcesUsedToProcessMsg,
        #{msg_name}"
      @current_resources.each do |k, v|
        RServiceBus.rlog "Commit resource, #{v.class.name}"
        v.commit
        v.finished
      end
    end

    def rollback(msg_name)
      @saga_storage.rollback
      RServiceBus.rlog "HandlerManager.rollbackResourcesUsedToProcessMsg,
        #{msg_name}"
      @current_resources.each do |k, v|
        begin
          RServiceBus.rlog "Rollback resource, #{v.class.name}"
          v.rollback
          v.finished
        rescue StandardError => e1
          puts "Caught nested exception rolling back, #{v.class.name}, for msg,
            #{msgName}"
          puts '****'
          puts e1.message
          puts e1.backtrace
          puts '****'
        end
      end
    end
  end
end
