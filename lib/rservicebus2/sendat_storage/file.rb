module RServiceBus2
  # Send at storage file
  class SendAtStorageFile
    def initialize(uri)
      @list = load(uri.path)
    end

    def load(path)
      return [] unless File.exist?(path)

      content = IO.read(path)

      return [] if content == ''

      YAML.load(content)
    end

    def add(msg)
      @list << msg
      save
    end

    def get_all
      @list
    end

    def delete(idx)
      @list.delete_at(idx)
      save
    end

    def save
      content = YAML.dump(@list)
      File.open(@uri.path, 'w') { |f| f.write(YAML.dump(content)) }
    end
  end
end
