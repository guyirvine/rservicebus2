# frozen_string_literal: true

require 'cgi'
require 'fileutils'
require 'pathname'

module RServiceBus2
  # Monitor for Directory
  class MonitorDirNotifier < Monitor
    attr_reader :path, :processing_folder, :filter

    def connect(uri)
      # Pass the path through the Dir object to check syntax on startup
      begin
        open_folder uri.path
        unless File.writable?(uri.path)
          puts "***** Directory is not writable, #{uri.path}.\n" \
               "***** Make the directory, #{uri.path}, writable and try again."
          abort
        end
      rescue Errno::ENOENT
        puts "***** Directory does not exist, #{uri.path}.\n" \
             "***** Create the directory, #{uri.path}, and try again.\n" \
             "***** eg, mkdir #{uri.path}"
        abort
      rescue Errno::ENOTDIR
        puts "***** The specified path does not point to a directory, #{uri.path}." \
             "***** Either repoint path to a directory, or remove, #{uri.path}, and create it as a directory." \
             "***** eg, rm #{uri.path} && mkdir #{uri.path}"
        abort
      end

      @path = uri.path

      if uri.query.nil?
        puts '***** Processing Directory is not specified.'
        puts '***** Specify the Processing Directory as a query string in the
              Path URI'
        puts "***** eg, '/#{uri.path}?processing=*ProcessingDir*"
        abort
      else
        parts = CGI.parse(uri.query)

        if parts.key? 'processing'
          processing_uri = URI.parse parts['processing'][0]
          begin
            open_folder processing_uri.path
            unless File.writable?(processing_uri.path)
              puts "***** 1Processing Directory is not writable,
                    #{processing_uri.path}."
              puts "***** Make the directory, #{processing_uri.path},
                    writable and try again."
              abort
            end
          rescue Errno::ENOENT
            puts "***** Processing Directory does not exist, #{processing_uri.path}." \
                 "***** Create the directory, #{processing_uri.path}, and try again." \
                 "***** eg, mkdir #{processing_uri.path}"
            abort
          rescue Errno::ENOTDIR
            puts "***** Processing Directory does not point to a directory, #{processing_uri.path}." \
                 "***** Either repoint path to a directory, or remove, #{processing_uri.path}, and create it as a directory.\n" \
                 "***** eg, rm #{processing_uri.path} && mkdir #{processing_uri.path}"
            abort
          end

          @processing_folder = processing_uri.path
        end

        @filter = '*'
        @filter = parts['filter'][0] if parts.key? 'filter'
      end
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
