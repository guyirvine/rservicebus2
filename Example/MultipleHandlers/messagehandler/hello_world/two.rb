class MessageHandlerHelloWorldTwo
  attr_accessor :bus

  def handle(_msg)
    puts 'MessageHandler_HelloWorld_Two: HelloWorld'
    @bus.reply('Reply from MessageHandler_HelloWorld_Two')
  end
end
