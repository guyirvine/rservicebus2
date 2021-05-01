# frozen_string_literal: true

require 'aws-sdk-dynamodb'

module RServiceBus2
  # AppResourceAWSDynamoDb
  class AppResourceAWSDynamoDb < AppResource
    def connect(uri)
      region = uri.host

      Aws::DynamoDB::Client.new(region: region)
    end

    def finished; end
  end
end
