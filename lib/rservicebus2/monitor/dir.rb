require 'cgi'
require 'zip/zip'
require 'zlib'

module RServiceBus2
  # Monitor Directory for files
  # rubocop:disable Metrics/ClassLength
  class MonitorDir < Monitor
    def connect(uri)
      # Pass the path through the Dir object to check syntax on startup
      begin
        input_dir = Dir.new(uri.path)
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

      @path = input_dir.path
      @input_filter = []

      return if uri.query.nil?
      parts = CGI.parse(uri.query)
      @querystringparts = parts
      if parts.key?('archive')
        archiveuri = URI.parse(parts['archive'][0])
        unless File.directory?(archiveuri.path)
          puts '***** Archive file name templating not yet supported.'
          puts "***** Directory's only."
          abort
        end
        @archivedir = archiveuri.path
      end

      return unless parts.key?('input_filter')

      if parts['input_filter'].count > 1
        puts 'Too many input_filters specified.'
        puts '*** ZIP, or GZ are the only valid input_filters.'
        abort
      end

      if parts['input_filter'][0] == 'ZIP'
      elsif parts['input_filter'][0] == 'GZ'
      elsif parts['input_filter'][0] == 'TAR'
      else
        puts 'Invalid input_filter specified.'
        puts '*** ZIP, or GZ are the only valid input_filters.'
        abort
      end
      @input_filter << parts['input_filter'][0]
    end

    def process_content(content)
      content
    end

    def read_content_from_zip_file(file_path)
      zip = Zip::ZipInputStream.open(file_path)
      zip.get_next_entry
      content = zip.read
      zip.close

      content
    end

    def read_content_from_gz_file(filepath)
      gz = Zlib::GzipReader.open(filepath)
      gz.read
    end

    # rubocop:disable Metrics/MethodLength
    def read_content_from_file(file_path)
      content = ''
      if @input_filter.length > 0
        if @input_filter[0] == 'ZIP'
          content = read_content_from_zip_file(file_path)
        elsif @input_filter[0] == 'GZ'
          content = read_content_from_gz_file(file_path)
        elsif @input_filter[0] == 'TAR'
          fail 'TAR reader not implemented'
        end

      else
        content = IO.read(file_path)
      end

      content
    end

    def process_path(file_path)
      content = read_content_from_file(file_path)
      payload = process_content(content)

      send(payload, URI.parse(URI.encode("file://#{file_path}")))
      content
    end

    def look
      file_processed = 0
      max_files_processed = 10

      file_list = Dir.glob("#{@path}/*")
      file_list.each do |file_path|
        if File.file?(file_path) != true
          RServiceBus2.log "Skipping directory, #{file_path}"
          next
        end
        RServiceBus2.log "Ready to process, #{file_path}"
        content = process_path(file_path)

        unless @archivedir.nil?
          basename = File.basename(file_path)
          new_file_path = "#{@archivedir}/#{basename}.
                            #{DateTime.now.strftime('%Y%m%d%H%M%S%L')}.zip"
          RServiceBus2.log "Writing to archive, #{new_file_path}"

          Zip::ZipOutputStream.open(new_file_path) do |zos|
            zos.put_next_entry(basename)
            zos.puts content
          end
        end
        File.unlink(file_path)

        file_processed += 1
        RServiceBus2.log "Processed #{file_processed} of #{file_list.length}."
        RServiceBus2.log "Allow system tick #{self.class.name}"
        break if file_processed >= max_files_processed
      end
    end
  end
end
