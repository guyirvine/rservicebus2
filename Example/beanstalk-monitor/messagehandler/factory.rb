# MessageHandlerFactory
class MessageHandlerFactory
  attr_accessor :bus, :sqs

  def handle(msg)
    puts "msg.payload: #{msg.payload}"
    puts "msg.uri: #{msg.uri}"
  end
end
