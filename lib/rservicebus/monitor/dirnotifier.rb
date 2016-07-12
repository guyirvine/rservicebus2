require 'cgi'
require 'fileutils'
require 'pathname'

module RServiceBus
  # Monitor for Directory
  class MonitorDirNotifier < Monitor
    attr_reader :Path, :ProcessingFolder, :Filter
    def connect(uri)
      # Pass the path through the Dir object to check syntax on startup
      begin
        open_folder uri.path
        unless File.writable?(uri.path)
          puts "***** Directory is not writable, #{uri.path}."
          puts "***** Make the directory, #{uri.path}, writable and try again."
          abort
        end
      rescue Errno::ENOENT
        puts "***** Directory does not exist, #{uri.path}."
        puts "***** Create the directory, #{uri.path}, and try again."
        puts "***** eg, mkdir #{uri.path}"
        abort
      rescue Errno::ENOTDIR
        puts "***** The specified path does not point to a directory,
              #{uri.path}."
        puts "***** Either repoint path to a directory, or remove, #{uri.path},
              and create it as a directory."
        puts "***** eg, rm #{uri.path} && mkdir #{uri.path}"
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
              puts "***** Processing Directory is not writable,
                    #{processingUri.path}."
              puts "***** Make the directory, #{processingUri.path},
                    writable and try again."
              abort
            end
          rescue Errno::ENOENT
            puts "***** Processing Directory does not exist,
                  #{processingUri.path}."
            puts "***** Create the directory, #{processingUri.path}, and try
                  again."
            puts "***** eg, mkdir #{processingUri.path}"
            abort
          rescue Errno::ENOTDIR
            puts "***** Processing Directory does not point to a directory,
                  #{processingUri.path}."
            puts "***** Either repoint path to a directory, or remove,
                  #{processingUri.path}, and create it as a directory."
            puts "***** eg, rm #{processingUri.path} && mkdir
                  #{processingUri.path}"
            abort
          end

          @processing_folder = processing_uri.path
        end

        @filter = '*'
        @filter = parts['filter'][0] if parts.key? 'filter'
      end
    end

    def look
      file_list = get_files
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

    def get_files
      Dir.glob(Pathname.new("#{@Path}").join(@Filter) ).select { |f| File.file?(f) }
    end
  end
end
