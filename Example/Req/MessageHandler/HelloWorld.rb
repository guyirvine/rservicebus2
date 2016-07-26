class MessageHandler_HelloWorld
  attr_accessor :bus

  def handle(msg)
    puts "Handling Hello World: #{msg.name}"
    @bus.reply("Hey. #{msg.name}")
  end
end
