class MessageHandler_Msg2
  attr_accessor :bus

  def handle(msg)
    @bus.reply(Msg3.new(msg.name + ', 3'))
  end
end
