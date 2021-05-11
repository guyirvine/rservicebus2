# frozen_string_literal: true

module RServiceBus2
  # Given a directory, this class is responsible loading Sagas
  class SagaLoader
    attr_reader :saga_list

    # Constructor
    # @param [RServiceBus2::Host] host instance
    # @param [Hash] appResources As hash[k,v] where k is the name of a
    #   resource, and v is the resource
    def initialize(host, saga_manager)
      @host = host
      @saga_manager = saga_manager
      @list_of_loaded_paths = {}
    end

    # Cleans the given path to ensure it can be used for as a parameter for the
    #  require statement.
    # @param [String] file_path the path to be cleaned
    def get_require_path(file_path)
      file_path = "./#{file_path}" unless file_path.start_with?('/')

      return file_path.sub('.rb', '') if File.exist?(file_path)

      abort("Filepath, #{file_path}, given for Saga require doesn't exist")
    end

    # Instantiate the saga named in sagaName from the file name in file_path
    # Exceptions will be raised if encountered when loading sagas. This is a
    # load time activity, so sagas should load correctly. As much information
    # as possible is returned to enable the saga to be fixed, or configuration
    # corrected.
    # @param [String] sagaName name of the saga to instantiate
    # @param [String] file_path the path to the file to be loaded
    # @return [RServiceBus2::Saga] the loader

    # rubocop:disable Metrics/MethodLength
    def load_saga_from_file(saga_name, file_path)
      require_path = get_require_path(file_path)

      require require_path
      begin
        saga = Object.const_get(saga_name)
      rescue StandardError => e
        puts "Expected class name: #{saga_name}, not found after require: #{require_path}" \
             "**** Check in #{file_path} that the class is named: #{saga_name}" \
             '( In case its not that )'
        raise e
      end
      saga
    end
    # rubocop:enable Metrics/MethodLength

    # Wrapper function
    # @param [String] file_path
    # @param [String] sagaName
    # @returns [RServiceBus2::Saga] saga

    # rubocop:disable Metrics/MethodLength
    def load_saga(file_path, saga_name)
      if @list_of_loaded_paths.key?(file_path)
        RServiceBus2.log "Not reloading, #{file_path}"
        return
      end

      RServiceBus2.rlog "file_path: #{file_path}"
      RServiceBus2.rlog "saga_name: #{saga_name}"

      saga = load_saga_from_file(saga_name, file_path)
      RServiceBus2.log "Loaded Saga: #{saga_name}"

      @saga_manager.register_saga(saga)

      @list_of_loaded_paths[file_path] = 1
    rescue StandardError => e
      puts "Exception loading saga from file: #{file_path}"
      puts e.message
      puts e.backtrace[0]
      abort
    end
    # rubocop:enable Metrics/MethodLength

    # This method is overloaded for unit tests
    # @param [String] path directory to check
    # @return [Array] a list of paths to files found in the given path
    def get_list_of_files_for_dir(path)
      list = Dir["#{path}/*"]

      RServiceBus2.rlog "SagaLoader.getListOfFilesForDir. path: #{path}, list: #{list}"

      list
    end

    # Extract the top level dir or file name as it is the msg name
    # @param [String] file_path path to check - this can be a directory or file
    def get_saga_name(file_path)
      base_name = File.basename(file_path)
      ext_name = File.extname(base_name)

      saga_name = base_name.sub(ext_name, '')

      "saga_#{saga_name}".gsub(/(?<=_|^)(\w)/) { Regexp.last_match(1).upcase }.gsub(/(?:_)(\w)/, '\1')
    end

    # Entry point for loading Sagas
    # @param [String] base_dir directory to check - should not have trailing slash
    def load_sagas_from_path(base_dir)
      RServiceBus2.rlog "SagaLoader.loadSagasFromPath. base_dir: #{base_dir}"

      get_list_of_files_for_dir(base_dir).each do |file_path|
        unless file_path.end_with?('.')
          saga_name = get_saga_name(file_path)
          load_saga(file_path, saga_name)
        end
      end

      self
    end
  end
end
