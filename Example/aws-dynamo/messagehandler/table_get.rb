require 'uuidtools'

class MessageHandlerTableGet
  attr_accessor :aws

  def handle(msg)
    id = msg.id
    puts "Handling TableGet.id: #{id}"

    table_item = {
      table_name: 'GuysTmpTable',
      key: {
        Identifier: id
      }
    }

    puts "table_item: #{table_item}"
    result = @aws.get_item(table_item)

    puts "result: #{result}"
  end
end
