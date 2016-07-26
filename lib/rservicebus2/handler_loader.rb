module RServiceBus2
  # Given a directory, this class is responsible for finding
  #  msgnames,
  #  handlernames, and
  #  loading handlers
  class HandlerLoader
    attr_reader :handlerList

    # Constructor
    #
    # @param [RServiceBus2::Host] host instance
    # @param [Hash] appResources As hash[k,v] where k is the name of a
    #  resource, and v is the resource
    def initialize(host, handler_manager)
      @host = host

      @handler_manager = handler_manager

      @list_of_loaded_paths = {}
    end

    # Cleans the given path to ensure it can be used for as a parameter for the require statement.
    # @param [String] file_path the path to be cleaned
    def get_require_path(file_path)
      file_path = './' + file_path unless file_path.start_with?('/')

      return file_path.sub('.rb', '') if File.exist?(file_path)

      abort('Filepath, ' + file_path + ", given for messagehandler require
        doesn't exist")
    end

    # Instantiate the handler named in handlerName from the file name in
    # file_path. Exceptions will be raised if encountered when loading handlers.
    # This is a load time activity, so handlers should load correctly. As much
    # information as possible is returned to enable the handler to be fixed,
    # or configuration corrected.
    # @param [String] handler_name name of the handler to instantiate
    # @param [String] file_path the path to the file to be loaded
    # @return [RServiceBus2::Handler] the loader
    def load_handler_from_file(handler_name, file_path)
      require_path = get_require_path(file_path)

      require require_path
      begin
        handler = Object.const_get(handler_name).new
      rescue StandardError => e
        puts 'Expected class name: ' + handler_name + ', not found after
          require: ' + require_path
        puts '**** Check in ' + file_path + ' that the class is named : ' +
          handler_name
        puts '( In case its not that )'
        raise e
      end

      handler
    end

    # Wrapper function
    #
    # @param [String] file_path
    # @param [String] handler_name
    # @returns [RServiceBus2::Handler] handler
    def load_handler(msg_name, file_path, handler_name)
      if @list_of_loaded_paths.key?(file_path)
        RServiceBus2.log "Not reloading, #{file_path}"
        return
      end

      begin
        RServiceBus2.rlog 'file_path: ' + file_path
        RServiceBus2.rlog 'handler_name: ' + handler_name

        handler = load_handler_from_file(handler_name, file_path)
        RServiceBus2.log 'Loaded Handler: ' + handler_name

        @handler_manager.add_handler(msg_name, handler)

        @list_of_loaded_paths[file_path] = 1
      rescue StandardError => e
        puts 'Exception loading handler from file: ' + file_path
        puts e.message
        puts e.backtrace[0]
        abort
      end
    end

    # This method is overloaded for unit tests
    #
    # @param [String] path directory to check
    # @return [Array] a list of paths to files found in the given path
    def get_list_of_files_for_dir(path)
      list = Dir[path + '/*']
      RServiceBus2.rlog "HandlerLoader.getListOfFilesForDir. path: #{path},
        list: #{list}"
      list
    end

    # Multiple handlers for the same msg can be placed inside a top level
    # directory. The msg name is than taken from the directory, and the
    # handlers from the files inside that directory
    #
    # @param [String] msg_name name of message
    # @param [String] base_dir directory to check for handlers of [msg_name]
    def load_handlers_from_second_level_path(msg_name, base_dir)
      get_list_of_files_for_dir(base_dir).each do |file_path|
        next if file_path.end_with?('.')

        ext_name = File.extname(file_path)
        if !File.directory?(file_path) && ext_name == '.rb'
          file_name = File.basename(file_path).sub('.rb', '')
          handler_name = "message_handler_#{msg_name}_#{file_name}".gsub(/(?<=_|^)(\w)/){$1.upcase}.gsub(/(?:_)(\w)/,'\1') # Classify

          load_handler(msg_name, file_path, handler_name)
        end
      end

      self
    end

    # Extract the top level dir or file name as it is the msg name
    #
    # @param [String] file_path path to check - this can be a directory or file
    def get_msg_name(file_path)
      base_name = File.basename(file_path)
      ext_name = File.extname(base_name)
      base_name.sub(ext_name, '')
    end

    # Load top level handlers from the given directory
    #
    # @param [String] baseDir directory to check - should not have trailing slash
    def load_handlers_from_top_level_path(base_dir)
      RServiceBus2.rlog "HandlerLoader.loadHandlersFromTopLevelPath. baseDir: #{base_dir}"
      get_list_of_files_for_dir(base_dir).each do |file_path|
        unless file_path.end_with?('.')
          msg_name = get_msg_name(file_path)
          if File.directory?(file_path)
            load_handlers_from_second_level_path(msg_name, file_path)
          else
            handler_name = "message_handler_#{msg_name}".gsub(/(?<=_|^)(\w)/){$1.upcase}.gsub(/(?:_)(\w)/,'\1') # Classify
            load_handler(msg_name, file_path, handler_name)
          end
        end
      end

      self
    end

    # Entry point for loading handlers
    #
    # @param [String] baseDir directory to check - should not have trailing
    #  slash
    def load_handlers_from_path(base_dir)
      load_handlers_from_top_level_path(base_dir)

      self
    end
  end
end
