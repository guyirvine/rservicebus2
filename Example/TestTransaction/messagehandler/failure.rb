require './contract.rb'

# Need to create a postgresql db called rservicebus2_test, and a table
#  called table_tbl
class MessageHandlerFailure
  attr_accessor :bus
  def handle(_msg)
    @bus.send(HelloWorld.new(1))
  end
end
