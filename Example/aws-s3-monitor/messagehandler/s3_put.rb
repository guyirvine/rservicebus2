# MessageHandlerS3Put
class MessageHandlerS3Put
  attr_accessor :bus, :s3

  def handle(msg)
    bucket_name = 'guystmpbucket'
    response = @s3.put_object(
      bucket: bucket_name,
      key: msg.object_key,
      body: msg.payload
    )

    puts "response.etag: #{response.etag}"
  end
end
