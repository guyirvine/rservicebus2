module RServiceBus2
  # Marshals configuration information for an rservicebus host
  class Config
    attr_reader :app_name, :message_endpoint_mappings, :handler_path_list,
                :saga_path_list, :error_queue_name, :max_retries,
                :forward_received_messages_to, :subscription_uri,
                :stat_output_countdown, :contract_list, :lib_list,
                :forward_sent_messages_to, :mq_host

    def initialize
      puts 'Cannot instantiate config directly.'
      puts 'For production, use ConfigFromEnv.'
      puts 'For debugging or testing, you could try ConfigFromSetter'
      abort
    end

    def log(string)
      puts string
    end

    def get_value(name, default = nil)
      value = (ENV[name].nil? || ENV[name] == '') ? default : ENV[name]
      log "Env value: #{name}: #{value}"
      value
    end

    # Marshals paths for message handlers
    # Note. trailing slashs will be stripped
    # Expected format: <path 1>;<path 2>
    def load_handler_path_list
      paths = get_value('MSGHANDLERPATH', './messagehandler')
      @handler_path_list = []
      paths.split(';').each do |path|
        @handler_path_list << path.strip.chomp('/')
      end

      self
    end

    def load_saga_path_list
      paths = get_value('SAGAPATH', './Saga')
      @saga_path_list = []
      paths.split(';').each do |path|
        @saga_path_list << path.strip.chomp('/')
      end

      self
    end

    def load_host_section
      @app_name = get_value('APPNAME', 'RServiceBus2')
      @error_queue_name = get_value('ERROR_QUEUE_NAME', 'error')
      @max_retries = get_value('MAX_RETRIES', '5').to_i
      @stat_output_countdown = get_value('STAT_OUTPUT_COUNTDOWN', '100').to_i
      @subscription_uri = get_value('SUBSCRIPTION_URI',
                                    "file:///tmp/#{app_name}_subscriptions.yaml")

      audit_queue_name = get_value('AUDIT_QUEUE_NAME')
      if audit_queue_name.nil?
        @forward_sent_messages_to = get_value('FORWARD_SENT_MESSAGES_TO')
        @forward_received_messages_to = get_value('FORWARD_RECEIVED_MESSAGES_TO')
      else
        @forward_sent_messages_to = audit_queue_name
        @forward_received_messages_to = audit_queue_name
      end

      self
    end

    def ensure_contract_file_exists(path)
      unless File.exist?(path) || File.exist?("#{path}.rb")
        puts 'Error while processing contracts'
        puts "*** path, #{path}, provided does not exist as a file"
        abort
      end
      unless File.extname(path) == '' || File.extname(path) == '.rb'
        puts 'Error while processing contracts'
        puts "*** path, #{path}, should point to a ruby file, with extention .rb"
        abort
      end
    end

    # Marshals paths for contracts
    # Note. .rb extension is optional
    # Expected format: /one/two/contracts
    def load_contracts
      @contract_list = []
      # This is a guard clause in case no Contracts have been specified
      # If any guard clauses have been specified, then execution should drop
      #   to the second block
      return self if get_value('CONTRACTS').nil?

      get_value('CONTRACTS', './contract').split(';').each do |path|
        ensure_contract_file_exists(path)
        @contract_list << path
      end
      self
    end

    # Marshals paths for lib
    # Note. .rb extension is optional
    # Expected format: /one/two/contracts
    def load_libs
      @lib_list = []

      paths = get_value('LIB')
      paths = './lib' if paths.nil? && File.exist?('./lib')
      return self if paths.nil?

      paths.split(';').each do |path|
        log "Loading libs from, #{path}"
        unless File.exist?(path)
          puts 'Error while processing libs'
          puts "*** path, #{path}, should point to a ruby file, with extention
                .rb, or"
          puts "*** path, #{path}, should point to a directory than conatins
                ruby files, that have extention .rb"
          abort
        end
        @lib_list << path
      end
      self
    end

    def configure_mq
      @mq_host = get_value('MQ', 'beanstalk://localhost')
      self
    end

    # Marshals paths for working_dirs
    # Note. trailing slashs will be stripped
    # Expected format: <path 1>;<path 2>
    def load_working_dir_list
      puts "Config.load_working_dir_list.1"
      puts "Config.load_working_dir_list.2 #{@contract_list}"
      path_list = get_value('WORKING_DIR', './')
      return self if path_list.nil?

      path_list.split(';').each do |path|
        path = path.strip.chomp('/')
        unless Dir.exist?("#{path}")
          puts 'Error while processing working directory list'
          puts "*** path, #{path}, does not exist"
          abort
        end
        @handler_path_list << "#{path}/messagehandler" if Dir.exist?("#{path}/messagehandler")
        @saga_path_list << "#{path}/saga" if Dir.exist?("#{path}/saga")
        @contract_list << "#{path}/contract.rb" if File.exist?( "#{path}/contract.rb" )
        @lib_list << "#{path}/lib" if File.exist?("#{path}/lib")
      end
      self
    end
  end

  # Class
  class ConfigFromEnv < Config
    def initialize
    end
  end

  # Class
  class ConfigFromSetter < Config
    attr_writer :appName, :messageEndpointMappings, :handler_path_list, :errorQueueName, :maxRetries, :forward_received_messages_to, :beanstalkHost
    def initialize
    end
  end
end
