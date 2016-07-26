class Saga_MySaga < RServiceBus2::Saga_Base
  attr_accessor :bus

  def startwith_msg1(msg)
    @bus.send(Msg2.new(msg.name + ', 2'))
  end

  def handle_msg3(msg)
    @bus.send(Msg4.new(msg.name + ', 4'))
    finish
  end
end
