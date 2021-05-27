# frozen_string_literal: true

require 'fileutils'
require 'rservicebus2/mq'

module RServiceBus2
  # Beanstalk client implementation.
  class MQFile < MQ
    # Connect to the broker

    def initialize(uri)
      super

      FileUtils.mkdir_p("#{@uri.path}/#{@local_queue_name}")
      @timeout = RServiceBus2.get_value('QUEUE_TIMEOUT', '5').to_i
    end

    def subscribe(queue_name)
      path = "#{@uri.path}/#{queue_name}"
      FileUtils.mkdir_p(path)
      @local_queue_name = queue_name
    end

    # Get next msg from queue
    # rubocop:disable Metrics/MethodLength
    def pop
      time = @timeout
      while time.positive?
        files = Dir.glob("#{@uri.path}/#{@local_queue_name}/*.msg")
        if files.positive?
          @file_path = files[0]
          @body = IO.read(@file_path)
          return @body
        end
        time -= 1
        sleep(1)
      end

      raise NoMsgToProcess if files.length.zero?
    end
    # rubocop:enable Metrics/MethodLength

    def ack
      FileUtils.rm @file_path
    end

    def send(queue_name, msg)
      FileUtils.mkdir_p("#{@uri.path}/#{queue_name}")
      IO.write("#{@uri.path}/#{queue_name}/#{rand}.msg", msg)
    end
  end
end
