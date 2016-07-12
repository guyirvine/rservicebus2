module RServiceBus
  # AppResourceDir
  class AppResourceDir < AppResource
    def connect(uri)
      begin
        input_dir = Dir.new(uri.path)
        unless File.writable?(uri.path)
          puts "*** Warning. Directory is not writable, #{uri.path}."
          puts "*** Warning. Make the directory, #{uri.path}, writable and try
                again."
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

      input_dir
    end
  end
end
