require './contract.rb'

class MessageHandlerHelloWorld
  attr_accessor :bus

  def handle(_msg)
    @bus.publish(HelloWorldEvent.new('Hello World'))
  end
end
