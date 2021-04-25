require 'aws-sdk-sqs'
require 'aws-sdk-sts'
require 'rservicebus2/mq'

module RServiceBus2
  # Beanstalk client implementation.
  class MQAWS < MQ
    # Connect to the broker
    # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    def connect(region, port)
      begin
        @max_job_size = 4_194_304
        @region = region

        sts_client = Aws::STS::Client.new(region: region)
        @caller_identity_account = sts_client.get_caller_identity.account
      rescue StandardError => e
        puts 'Error connecting to AWS'
        puts "Host string, #{region}"
        puts e.message
        puts e.backtrace
        abort
      end
    end

    def subscribe(queuename)
      # For example:
      # 'https://sqs.us-east-1.amazonaws.com/111111111111/my-queue'
      @queue_url = 'https://sqs.' + @region + '.amazonaws.com/' +
        @caller_identity_account + '/' + queuename
      @sqs_client = Aws::SQS::Client.new(region: @region)
    end

    # Get next msg from queue
    def pop
      begin
        response = @sqs_client.receive_message(
          queue_url: @queue_url,
          max_number_of_messages: 1
        )

        if response.messages.count.zero?
          raise NoMsgToProcess
        end

        response.messages.each do |message|
          @job = message
        end
      rescue StandardError => e
        raise e
      end
      @job.body
    end

    def return_to_queue
#      @job.release if @job
      @job = nil
    end

    def ack
      @sqs_client.delete_message({
        queue_url: @queue_url,
        receipt_handle: @job.receipt_handle
      })
      @job = nil
    end

    def send(queue_name, msg)
      if msg.length > @max_job_size
        puts '***Attempting to send a msg which will not fit on queue.'
        puts "***Msg size, #{msg.length}, max msg size, #{@max_job_size}."
        fail JobTooBigError, "Msg size, #{msg.length}, max msg size,
              #{@max_job_size}"
      end

      queue_url = 'https://sqs.' + @region + '.amazonaws.com/' +
        @caller_identity_account + '/' + queue_name

      @sqs_client.send_message(
        queue_url: queue_url,
        message_body: msg
      )
    end
  end
end
