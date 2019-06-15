require 'HelperClass'
require 'BaseHelperClass'

class MessageHandlerHelloWorld
  attr_accessor :bus

  def handle(msg)
    puts 'Handling Hello World: ' + msg.name
    @bus.reply(HelperClass.new.msg)
  end
end
