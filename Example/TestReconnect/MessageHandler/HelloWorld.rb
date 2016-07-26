require './Contract.rb'

# Need to create a postgresql db called rservicebus2_test, and a table
#  called table_tbl
class MessageHandler_HelloWorld
  attr_accessor :bus, :bcs
  def handle(msg)
    @counter = 0 if @counter.nil?
    @counter += 1
    fail 'Manually generated error for testng' if @counter == 1

    count = @bcs.queryForValue('SELECT count(*) FROM table_tbl;', [])
    puts "Handling Hello World: #{msg.name}. Count: #{count}"

    @counter = 0
  end
end
