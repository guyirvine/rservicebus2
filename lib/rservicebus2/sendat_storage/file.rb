# frozen_string_literal: true

module RServiceBus2
  # Send at storage file
  class SendAtStorageFile
    def initialize(uri)
      RServiceBus2.log "SendAtStorageFile configured: #{uri.path}"
      @list = load(uri.path)
      puts "@list: #{@list.class.name}"
      @path = uri.path
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

    def all
      @list
    end

    def delete(idx)
      @list.delete_at(idx)
      save
    end

    def save
      content = YAML.dump(@list)
      File.open(@path, 'w') { |f| f.write(content) }
    end
  end
end
