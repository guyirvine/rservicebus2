require 'uuidtools'

class MessageHandlerTablePut
  attr_accessor :bus, :aws

  def handle(msg)
    id = UUIDTools::UUID.random_create.to_s

    seq = Time.now.strftime('%Y%m%d%H%M%S')

    table_item = {
      table_name: 'GuysTmpTable',
      item: {
        Identifier: id,
        name: "Wiggle #{seq}"
      }
    }

    @aws.put_item(table_item)
    puts "Handled TablePut.id: #{id}"

    @bus.send(TableGet.new(id))
  end
end
