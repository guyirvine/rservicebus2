class MessageHandlerMsg2
  attr_accessor :bus

  def handle(msg)
    @bus.reply(Msg3.new(msg.name + ', 3'))
    File.write('/tmp/saga.txt', "Msg2: #{msg.name}\n", File.size('/tmp/saga.txt'), mode: 'a')
    sleep(10)
  end
end
