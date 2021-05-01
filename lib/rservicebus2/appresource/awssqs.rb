require 'aws-sdk-sqs'
require 'aws-sdk-sts'

module RServiceBus2
  # AppResourceAWSDynamoDb
  class AppResourceAWSSQS < AppResource
    def connect(uri)
      queue_name = uri.path.sub('/', '')

      region = uri.host

      sts_client = Aws::STS::Client.new(region: region)
      caller_identity_account = sts_client.get_caller_identity.account

      queue_url = "https://sqs.#{region}.amazonaws.com/" \
                  "#{caller_identity_account}/#{queue_name}"
      {
        client: Aws::SQS::Client.new(region: region),
        url: queue_url
      }
    end

    def finished; end
  end
end
