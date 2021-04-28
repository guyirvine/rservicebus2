# S3Put
class S3Put
  attr_reader :object_key, :payload

  def initialize(object_key, payload)
    @object_key = object_key
    @payload = payload
  end
end
