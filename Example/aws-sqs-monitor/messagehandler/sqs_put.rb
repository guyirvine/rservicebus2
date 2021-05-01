# MessageHandlerS3Put
class MessageHandlerSqsPut
  attr_accessor :bus, :sqs

  def handle(msg)
    puts "url #{@sqs[:url]}"
    @sqs[:client].send_message(
      queue_url: @sqs[:url],
      message_body: msg.payload
    )
  end
end
