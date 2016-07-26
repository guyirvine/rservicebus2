module RServiceBus2
  # Saga Storage Dir
  class SagaStorageDir
    # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    def initialize(uri)
      @saga_dir = uri.path

      Dir.new(@saga_dir)
      unless File.writable?(@saga_dir)
        puts "***** Directory is not writable, #{@saga_dir}."
        puts "***** Make the directory, #{@saga_dir}, writable and try again."
        puts '***** Or, set the Saga Directory explicitly by,
                SAGA_URI=<dir://path/to/saga>'
        abort
      end
    rescue Errno::ENOENT
      puts "***** Directory does not exist, #{@saga_dir}."
      puts "***** Create the directory, #{@saga_dir}, and try again."
      puts "***** eg, mkdir #{@saga_dir}"
      puts '***** Or, set the Saga Directory explicitly by,
              SAGA_URI=<dir://path/to/saga>'
      abort
    rescue Errno::ENOTDIR
      puts "***** The specified path does not point to a directory,
              #{@saga_dir}."
      puts "***** Either repoint path to a directory, or remove,
              #{@saga_dir}, and create it as a directory."
      puts "***** eg, rm #{@saga_dir} && mkdir #{@saga_dir}"
      puts '***** Or, set the Saga Directory explicitly by,
              SAGA_URI=<dir://path/to/saga>'
      abort
    end

    # Start
    def begin
      @list = []
      @deleted = []
    end

    # Set
    def set(data)
      path = get_path(data.correlation_id)
      @list << Hash['path', path, 'data', data]
    end

    # Get
    def get(correlation_id)
      path = get_path(correlation_id)
      data = load(path)
      @list << Hash['path', path, 'data', data]

      data
    end

    # Finish
    def commit
      @list.each do |e|
        File.open(e['path'], 'w') { |f| f.write(YAML.dump(e['data'])) }
      end
      @deleted.each do |correlation_id|
        File.unlink(get_path(correlation_id))
      end
    end

    def rollback
    end

    def delete(correlation_id)
      @deleted << correlation_id
    end

    # Detail Functions
    def get_path(correlation_id)
      "#{@saga_dir}/saga-#{correlation_id}"
    end

    def load(path)
      return {} unless File.exist?(path)

      content = IO.read(path)

      return {} if content == ''

      YAML.load(content)
    end
  end
end
