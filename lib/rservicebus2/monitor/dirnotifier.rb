# frozen_string_literal: true

require 'cgi'
require 'fileutils'
require 'pathname'

module RServiceBus2
  # Monitor for Directory
  class MonitorDirNotifier < Monitor
    attr_reader :path, :processing_folder, :filter

    def directory_not_writable(path, param_name)
      "***** #{param_name} is not writable, #{path}.\n" \
      "***** Make the directory, #{path}, writable and try again."
    end

    def directory_does_not_exist(path, param_name)
      "***** #{param_name} does not exist, #{path}.\n" \
      "***** Create the directory, #{path}, and try again.\n" \
      "***** eg, mkdir #{path}"
    end

    def path_is_not_a_directory(path)
      "***** The specified path does not point to a directory, #{path}.\n" \
      "***** Either repoint path to a directory, or remove, #{path}, and create it as a directory.\n" \
      "***** eg, rm #{path} && mkdir #{path}"
    end

    def processing_directory_not_specified(path)
      '***** Processing Directory is not specified.' \
      '***** Specify the Processing Directory as a query string in the Path URI' \
      "***** eg, '/#{path}?processing=*ProcessingDir*'"
    end

    def validate_directory(path, param_name)
      open_folder path
      return if File.writable?(path)

      puts directory_not_writable(path, param_name)
      abort
    rescue Errno::ENOENT
      puts directory_does_not_exist(path, param_name)
      abort
    rescue Errno::ENOTDIR
      puts path_is_not_a_directory(path)
      abort
    end

    def validate_processing_directory(uri)
      if uri.query.nil?
        puts processing_directory_not_specified(uri.path)
        abort
      end

      parts = CGI.parse(uri.query)
      return unless parts.key? 'processing'

      processing_uri = URI.parse parts['processing'][0]
      validate_directory processing_uri.path, 'Processing Directory'
      @processing_folder = processing_uri.path
    end

    def connect(uri)
      # Pass the path through the Dir object to check syntax on startup

      validate_directory uri, 'Directory'
      @path = uri.path
      validate_processing_directory(uri)

      @filter = '*'
      @filter = parts['filter'][0] if parts.key? 'filter'
    end

    def look
      file_list = files
      file_list.each do |file_path|
        new_path = move_file(file_path, @processing_folder)
        send(nil, URI.parse("file://#{new_path}"))
      end
    end

    def open_folder(path)
      Dir.new path
    end

    def move_file(src, dest)
      FileUtils.mv(src, dest)
      filename = Pathname.new(src).basename
      Pathname.new(dest).join(filename)
    end

    def files
      Dir.glob(Pathname.new(@path).join(@filter)).select { |f| File.file?(f) }
    end
  end
end
