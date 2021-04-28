require 'aws-sdk-s3'

module RServiceBus2
  # AppResourceAWSDynamoDb
  class AppResourceAWSS3 < AppResource
    # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    def connect(uri)
      region = uri.host

      Aws::S3::Client.new(region: region)
    end

    def finished
    end
  end
end
