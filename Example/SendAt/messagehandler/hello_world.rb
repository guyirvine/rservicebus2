class MessageHandlerHelloWorld
  attr_accessor :bus

  def handle(msg)
    puts "Handling Hello World: #{msg.name}"
    @bus.reply("Hey. #{msg.name}", Time.now + 3)
  end
end
