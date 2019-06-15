class MessageHandlerHelloWorld
  def handle(msg)
    puts 'Handling Hello World: ' + msg.class.name
  end
end
