require 'aws-sdk-dynamodb'

module RServiceBus2
  # AppResourceAWSDynamoDb
  class AppResourceAWSDynamoDb < AppResource
    # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    def connect(uri)
      region = uri.host

      aws = Aws::DynamoDB::Client.new(region: region)
      puts "aws #{aws}"
      aws
    end

    def finished
    end
  end
end
