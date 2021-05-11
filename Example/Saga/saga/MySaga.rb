class SagaMySaga < RServiceBus2::SagaBase
  attr_accessor :bus

  def start_with_msg1(msg)
    @bus.send(Msg2.new("#{msg.name}, 2"))
    File.write('/tmp/saga.txt', "Saga.1: #{msg.name}\n", File.size('/tmp/saga.txt'), mode: 'a')
  end

  def handle_msg3(msg)
    @bus.send(Msg4.new("#{msg.name}, 4"))
    File.write('/tmp/saga.txt', "Saga.3: #{msg.name}\n", File.size('/tmp/saga.txt'), mode: 'a')
    finish
  end
end
