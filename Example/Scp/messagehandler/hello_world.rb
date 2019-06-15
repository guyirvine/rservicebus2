class MessageHandler_HelloWorld
  attr_accessor :bus, :datadir, :scpupload
  def handle(_msg)
    file_path = "#{@datadir.path}/data.txt"
    RServiceBus2.rlog "Writing to file: #{file_path}"
    IO.write(file_path, 'File Content')
    RServiceBus2.rlog "Scp file, #{file_path}"
    @scpupload.upload(file_path)
  end
end
