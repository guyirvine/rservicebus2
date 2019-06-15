require 'fileutils'
require 'rservicebus2/mq'

module RServiceBus2
  # Beanstalk client implementation.
  class MQFile < MQ
    # Connect to the broker
    # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    
    def initialize(uri)
      if uri.is_a? URI
        @uri = uri
      else
        puts 'uri must be a valid URI'
        abort
      end

      FileUtils.mkdir_p(@uri.path)
      @local_queue_name = RServiceBus2.get_value('APPNAME', 'RServiceBus')
      FileUtils.mkdir_p("#{@uri.path}/#{@local_queue_name}")
      @timeout = RServiceBus2.get_value('QUEUE_TIMEOUT', '5').to_i
    end

    def subscribe(queue_name)
      path = "#{@uri.path}/#{queue_name}"
      FileUtils.mkdir_p(path)
      @local_queue_name = queue_name
    end

    # Get next msg from queue
    def pop
      time = @timeout
      while time > 0
        files = Dir.glob("#{@uri.path}/#{@local_queue_name}/*.msg")
        if files.length > 0
          @file_path = files[0] 
          @body = IO.read(@file_path)
	  return @body
        end
	time -= 1
	sleep(1)
      end
	
      raise NoMsgToProcess if files.length == 0
    end

    def return_to_queue
    end

    def ack
      FileUtils.rm @file_path
    end

    def send(queue_name, msg)
      FileUtils.mkdir_p("#{@uri.path}/#{queue_name}")
      IO.write("#{@uri.path}/#{queue_name}/#{rand()}.msg", msg)
    end
  end
end
