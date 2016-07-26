require './Contract.rb'

class MessageHandler_HelloWorldEvent
  attr_accessor :bus

  def handle(msg)
    puts "Handling Hello World: #{msg.name}"
  end
end
