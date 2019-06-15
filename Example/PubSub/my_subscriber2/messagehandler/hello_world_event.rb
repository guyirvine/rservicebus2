require './contract.rb'

class MessageHandlerHelloWorldEvent
  attr_accessor :bus

  def handle(msg)
    puts "Handling Hello World: #{msg.name}"
  end
end
