require './contract.rb'
# Need to create a postgresql db called rservicebus2_test, and a table
#  called table_tbl
class MessageHandlerHelloWorld
  attr_accessor :bus, :test
  def handle(msg)
    @test.execute('UPDATE table1 SET field1 = 2', [])
    @bus.send(TestMsg.new)
    fail 'A user based exception' if msg.id == 1
  end
end
