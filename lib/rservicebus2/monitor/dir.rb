# frozen_string_literal: true

require 'cgi'
require 'zip/zip'
require 'zlib'

module RServiceBus2
  # Monitor Directory for files

  # rubocop:disable Metrics/ClassLength
  class MonitorDir < Monitor
    # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
    def input_dir(uri)
      # Pass the path through the Dir object to check syntax on startup
      return Dir.new(uri.path) if File.writable?(uri.path)

      puts "***** Directory is not writable, #{uri.path}.\n" \
           "***** Make the directory, #{uri.path}, writable and try again."
      abort
    rescue Errno::ENOENT
      puts "***** Directory does not exist, #{uri.path}.\n" \
            "***** Create the directory, #{uri.path}, and try again.\n" \
            "***** eg, mkdir #{uri.path}"
      abort
    rescue Errno::ENOTDIR
      puts "***** The specified path does not point to a directory, #{uri.path}.\n" \
            "***** Either repoint path to a directory, or remove, #{uri.path}, and create it as a directory.\n" \
            "***** eg, rm #{uri.path} && mkdir #{uri.path}"
      abort
    end
    # rubocop:enable Metrics/MethodLength,Metrics/AbcSize

    def initialise_archive(parts)
      return unless parts.key?('archive')

      archiveuri = URI.parse(parts['archive'][0])
      unless File.directory?(archiveuri.path)
        puts '***** Archive file name templating not yet supported.'
        puts "***** Directory's only."
        abort
      end
      @archivedir = archiveuri.path
    end

    def initialise_input_filter(parts)
      if parts['input_filter'].count > 1
        puts 'Too many input_filters specified.\n*** ZIP, or GZ are the only valid input_filters.'
        abort
      end

      unless %w[ZIP GZ TAR].include?(parts['input_filter'][0]).nil?
        puts 'Invalid input_filter specified.\n' \
             '*** ZIP, or GZ are the only valid input_filters.'
        abort
      end

      @input_filter << parts['input_filter'][0]
    end

    def connect(uri)
      @path = input_dir(uri).path
      @input_filter = []

      return if uri.query.nil?

      parts = CGI.parse(uri.query)
      @querystringparts = parts
      initialise_archive(parts)

      initialise_input_filter(parts) if parts.key?('input_filter')
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
      if @input_filter.positive?
        case @input_filter[0]
        when 'ZIP'
          content = read_content_from_zip_file(file_path)
        when 'GZ'
          content = read_content_from_gz_file(file_path)
        else
          raise "#{@input_filter[0]} reader not implemented."
        end

      else
        content = IO.read(file_path)
      end

      content
    end
    # rubocop:enable Metrics/MethodLength

    def archive_file(file_path, content)
      basename = File.basename(file_path)
      new_file_path = "#{@archivedir}/#{basename}.#{Time.now.strftime('%Y%m%d%H%M%S%L')}.zip"
      RServiceBus2.log "Writing to archive, #{new_file_path}"

      Zip::ZipOutputStream.open(new_file_path) do |zos|
        zos.put_next_entry(basename)
        zos.puts content
      end
    end

    def process_path(file_path)
      if File.file?(file_path) != true
        RServiceBus2.log "Skipping directory, #{file_path}"
        return
      end

      RServiceBus2.log "Ready to process, #{file_path}"
      content = read_content_from_file(file_path)
      payload = process_content(content)

      send(payload, URI.parse(CGI.escape("file://#{file_path}")))

      archive_file(file_path, content) unless @archivedir.nil?

      File.unlink(file_path)
    end

    def look
      file_processed = 0
      max_files_processed = 10

      file_list = Dir.glob("#{@path}/*")
      file_list.each do |file_path|
        process_path(file_path)

        file_processed += 1
        RServiceBus2.log "Processed #{file_processed} of #{file_list.length}.\nAllow system tick #{self.class.name}"

        break if file_processed >= max_files_processed
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
