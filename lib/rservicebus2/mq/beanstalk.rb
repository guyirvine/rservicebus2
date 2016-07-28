require 'beanstalk-client'
require 'rservicebus2/mq'

module RServiceBus2
  # Beanstalk client implementation.
  class MQBeanstalk < MQ
    # Connect to the broker
    # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    def connect(host, port)
      port ||= 11_300
      string = "#{host}:#{port}"

      begin
        @beanstalk = Beanstalk::Pool.new([string])
        @max_job_size = @beanstalk.stats['max-job-size']
        if @max_job_size < 4_194_304
          puts "***WARNING: Lowest recommended.max-job-size is 4m, current
                max-job-size, #{@max_job_size.to_f / (1024 * 1024)}m"
          puts '***WARNING: Set the job size with the -z switch, eg
                /usr/local/bin/beanstalkd -z 4194304'
        end
      rescue StandardError => e
        puts 'Error connecting to Beanstalk'
        puts "Host string, #{string}"
        if e.message == 'Beanstalk::NotConnected'
          puts '***Most likely, beanstalk is not running. Start beanstalk,
                  and try running this again.'
          puts "***If you still get this error, check beanstalk is running
                  at, #{string}"
        else
          puts e.message
          puts e.backtrace
        end
        abort
      end
    end

    def subscribe(queuename)
      @beanstalk.watch(queuename)
    end

    # Get next msg from queue
    def pop
      begin
        @job = @beanstalk.reserve @timeout
      rescue StandardError => e
        raise NoMsgToProcess if e.message == 'TIMED_OUT'
        raise e
      end
      @job.body
    end

    def return_to_queue
      @job.release
    end

    def ack
      @job.delete
      @job = nil
    end

    def send(queue_name, msg)
      if msg.length > @max_job_size
        puts '***Attempting to send a msg which will not fit on queue.'
        puts "***Msg size, #{msg.length}, max msg size, #{@max_job_size}."
        fail JobTooBigError, "Msg size, #{msg.length}, max msg size,
              #{@max_job_size}"
      end
      @beanstalk.use(queue_name)
      @beanstalk.put(msg)
    end
  end
end
