module RServiceBus
  # State Storage on the file system
  class StateStorageDir
    def initialize(uri)
      @state_dir = uri.path

      inputdir = Dir.new(@state_dir)
      unless File.writable?(@state_dir)
        puts "***** Directory is not writable, #{@state_dir}."
        puts "***** Make the directory, #{@state_dir}, writable and try
              again."
        puts '***** Or, set the State Directory explicitly by,
              STATE_URI=<dir://path/to/state>'
        abort
      end
    rescue Errno::ENOENT
      puts "***** Directory does not exist, #{@state_dir}."
      puts "***** Create the directory, #{@state_dir}, and try again."
      puts "***** eg, mkdir #{@state_dir}"
      puts '***** Or, set the State Directory explicitly by,
            STATE_URI=<dir://path/to/state>'
      abort
    rescue Errno::ENOTDIR
      puts "***** The specified path does not point to a directory,
            #{@state_dir}."
      puts "***** Either repoint path to a directory, or remove,
            #{@state_dir}, and create it as a directory."
      puts "***** eg, rm #{@state_dir} && mkdir #{@state_dir}"
      puts '***** Or, set the State Directory explicitly by,
            STATE_URI=<dir://path/to/state>'
      abort
    end

    def begin
      @list = []
    end

    def get(handler)
      path = get_path(handler)
      hash = load(path)
      @list << Hash['path', path, 'hash', hash]

      hash
    end

    def commit
      @list.each do |e|
        File.open(e['path'], 'w') { |f| f.write(YAML.dump(e['hash'])) }
      end
    end

    def get_path(handler)
      "#{@state_dir}/#{handler.class.name}"
    end

    def load(path)
      return {} unless File.exist?(path)

      content = IO.read(path)

      return {} if content == ''

      YAML.load(content)
    end
  end
end
