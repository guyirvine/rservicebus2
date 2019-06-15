class MessageHandlerHelloWorld2
  attr_accessor :bus

  def handle(msg)
    puts 'Handling Hello World2: ' + msg.name
  end
end
