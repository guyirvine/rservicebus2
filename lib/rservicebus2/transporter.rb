# frozen_string_literal: true

require 'beanstalk-client'
require 'rservicebus2'
require 'net/ssh/gateway'

module RServiceBus2
  class CouldNotConnectToDestination < StandardError
  end

  # TODO: Poison Message? Can I bury with timeout in beanstalk ?
  # Needs to end up on an error queue, destination queue may be down.
  # rubocop:disable Metrics/ClassLength
  class Transporter
    def get_value(name, default = nil)
      value = ENV[name].nil? || ENV[name] == '' ? default : ENV[name]
      RServiceBus2.log "Env value: #{name}: #{value}"
      value
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def connect_to_source_beanstalk
      source_queue_name = get_value('SOURCE_QUEUE_NAME', 'transport-out')
      source_url = get_value('SOURCE_URL', '127.0.0.1:11300')
      @source = Beanstalk::Pool.new([source_url])
      @source.watch source_queue_name

      RServiceBus2.log "Connected to, #{source_queue_name}@#{source_url}"
    rescue StandardError => e
      puts 'Error connecting to Beanstalk'
      puts "Host string, #{sourceUrl}"
      if e.message == 'Beanstalk::NotConnected'
        puts '***Most likely, beanstalk is not running. Start beanstalk, and try running this again.'
        puts "***If you still get this error, check beanstalk is running at, #{sourceUrl}"
      else
        puts e.message
        puts e.backtrace
      end
      abort
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def disconnect
      RServiceBus2.log "Disconnect from,
        #{@remote_user_name}@#{@remote_host_name}/#{@remote_queue_name}"
      @gateway&.shutdown!
      @gateway = nil
      @remote_host_name = nil

      @destination&.close
      @destination = nil

      @remote_user_name = nil
      @remote_queue_name = nil
    end

    # rubocop:disable Metrics/MethodLength
    def connect_local
      @local_port = get_value('LOCAL_PORT', 27_018).to_i
      RServiceBus2.rlog "Local Port: #{@local_port}"

      RServiceBus2.log "Connect SSH, #{@remote_user_name}@#{@remoteHostName}"
      # Open port 27018 to forward to 127.0.0.11300 on the remote host
      @gateway = Net::SSH::Gateway.new(@remote_host_name, @remote_user_name)
      @gateway.open('127.0.0.1', 11_300, @local_port)
      RServiceBus2.log "Connected to SSH, #{@remote_user_name}@#{@remote_host_name}"
    rescue Errno::EADDRINUSE
      puts "*** Local transport port in use, #{@local_port}"
      puts "*** Change local transport port, #{@localPort}, using format, LOCAL_PORT=#{@localPort + 1}"
      abort
    rescue Errno::EACCES
      puts "*** Local transport port specified, #{@local_port}, needs sudo access"
      puts '*** Change local transport port using format, LOCAL_PORT=27018'
      abort
    end
    # rubocop:enable Metrics/MethodLength

    def connect_destination
      destination_url = "127.0.0.1:#{@local_port}"
      RServiceBus2.rlog "Connect to Remote Beanstalk, #{destination_url}"
      @destination = Beanstalk::Pool.new([destinationUrl])
      RServiceBus2.rlog "Connected to Remote Beanstalk, #{destination_url}"
    rescue StandardError => e
      if e.message == 'Beanstalk::NotConnected'
        puts "***Could not connect to destination, check beanstalk is running at, #{destination_url}"
        raise CouldNotConnectToDestination
      end
      raise
    end

    def pull_config(remote_host_name)
      @remote_host_name = remote_host_name
      @remote_user_name = get_value("REMOTE_USER_#{remote_host_name.upcase}")
      return unless @remote_user_name.nil?

      RServiceBus2.log "**** Username not specified for Host, #{remoteHostName}"
      RServiceBus2.log "**** Add an environment variable of the form, REMOTE_USER_#{remoteHostName.upcase}=[USERNAME]"
      abort
    end

    def connect(remote_host_name)
      RServiceBus2.rlog "connect called, #{remote_host_name}"
      disconnect if @gateway.nil? || remoteHostName != @remote_host_name || @destination.nil?

      return unless @gateway.nil?

      # Get destination url from job
      pull_config(remote_host_name)
      connect_local
      connect_destination
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def process
      # Get the next job from the source queue
      job = @source.reserve @timeout
      msg = YAML.load(job.body)

      connect(msg.remote_host_name)

      @remote_queue_name = msg.remote_queue_name
      RServiceBus2.rlog "Put msg, #{msg.remote_queue_name}"
      @destination.use(msg.remote_queue_name)
      @destination.put(job.body)
      RServiceBus2.log "Msg put, #{msg.remote_queue_name}"

      unless ENV['AUDIT_QUEUE_NAME'].nil?
        @source.use ENV['AUDIT_QUEUE_NAME']
        @source.put job.body
      end
      # remove job
      job.delete

      RServiceBus2.log "Job sent to, #{@remote_user_name}@#{@remote_host_name}/#{@remote_queue_name}"
    rescue StandardError => e
      disconnect
      if e.message == 'TIMED_OUT'
        RServiceBus2.rlog 'No Msg'
        return
      end
      raise e
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def run
      @timeout = get_value('TIMEOUT', 5)
      connectToSourceBeanstalk
      loop { process }
      disconnect_from_remote_ssh
    end
  end
  # rubocop:enable Metrics/ClassLength
end
