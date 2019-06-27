class MessageHandlerMsg4
  attr_accessor :bus

  def handle(msg)
    File.write('/tmp/saga.txt', "Msg4\n", File.size('/tmp/saga.txt'), mode: 'a')
  end
end
