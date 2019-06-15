class MessageHandlerHelloWorldOne
  attr_accessor :bus

  def handle(_msg)
    puts 'MessageHandler_HelloWorld_One: HelloWorld'
    @bus.reply('Reply from MessageHandler_HelloWorld_One')
  end
end
