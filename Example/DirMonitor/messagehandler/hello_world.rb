require 'csv'

class MessageHandlerHelloWorld
  attr_accessor :bus, :output_dir

  def handle(msg)
    csv = CSV.parse(msg.payload)
      
	  IO.write(@output_dir.path + "/#{File.basename(msg.uri.path)}",
             msg.payload)
  end
end
