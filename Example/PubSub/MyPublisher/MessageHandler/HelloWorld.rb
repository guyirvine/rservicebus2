require './Contract.rb'

class MessageHandler_HelloWorld
  attr_accessor :bus

  def handle(_msg)
    @bus.publish(HelloWorldEvent.new('Hello World'))
  end
end
