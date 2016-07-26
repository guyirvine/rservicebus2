class MessageHandler_HelloWorld
  attr_accessor :Bus, :output_dir

  def handle(msg)
    IO.write(@output_dir.path + "/#{File.basename(msg.uri.path)}",
             msg.payload)
  end
end
