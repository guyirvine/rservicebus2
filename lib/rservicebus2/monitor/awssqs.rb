# frozen_string_literal: true

require 'aws-sdk-sqs'
require 'aws-sdk-sts'

module RServiceBus2
  # Monitor S3 Bucket for objects
  class MonitorAWSSQS < Monitor
    def connect(uri)
      queue_name = uri.path.sub('/', '')

      region = uri.host

      sts_client = Aws::STS::Client.new(region: region)
      caller_identity_account = sts_client.get_caller_identity.account

      @queue_url = "https://sqs.#{region}.amazonaws.com/#{caller_identity_account}/#{queue_name}"
      @sqs_client = Aws::SQS::Client.new(region: region)
    end

    def look
      response = @sqs_client.receive_message(queue_url: @queue_url, max_number_of_messages: 1)
      response.messages.each do |message|
        send(message.body, URI.parse(CGI.escape(@queue_url)))
        @sqs_client.delete_message(
          {
            queue_url: @queue_url,
            receipt_handle: message.receipt_handle
          }
        )
      end
    end
  end
end
