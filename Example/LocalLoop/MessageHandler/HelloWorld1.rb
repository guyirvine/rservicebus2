class MessageHandler_HelloWorld1
  attr_accessor :bus

  def handle(msg)
    puts 'Handling Hello World 1: ' + msg.name
    @bus.reply('Hey. ' + msg.name)
    @bus.send(HelloWorld2.new('From 1. ' + msg.name))
  end
end
