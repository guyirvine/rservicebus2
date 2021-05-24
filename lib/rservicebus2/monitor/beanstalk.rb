# frozen_string_literal: true

require 'beanstalk-client'
require 'cgi'

module RServiceBus2
  # Monitor S3 Bucket for objects
  class MonitorBeanstalk < Monitor
    def deduce_timeout(uri)
      return 5 if uri.query.nil?

      CGI.parse(u.query)['timeout1']&.first || 5
    end

    # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
    def connect(uri)
      @uri = uri
      @timeout = deduce_timeout(uri)

      queue_name = uri.path.sub('/', '')

      port ||= 11_300
      connection_string = "#{uri.host}:#{port}"
      @beanstalk = Beanstalk::Pool.new([connection_string])

      @beanstalk.watch(queue_name)
      @message_uri = "beanstalk://#{uri.host}:#{port}/#{queue_name}"
    rescue StandardError => e
      puts "Error connecting to Beanstalk, Host string, #{connection_string}"
      if e.message == 'Beanstalk::NotConnected'
        puts '***Most likely, beanstalk is not running. Start beanstalk, and try running this again.\n' \
             "***If you still get this error, check beanstalk is running at, #{connection_string}"
        abort
      end

      puts e.message
      puts e.backtrace
    end
    # rubocop:enable Metrics/MethodLength,Metrics/AbcSize

    def look
      job = @beanstalk.reserve @timeout
      send(job.body, "#{@message_uri}/#{job.id}")
      job_body = job.body
      job.delete
      job_body
    rescue StandardError => e
      return if e.message == 'TIMED_OUT'

      raise e
    end
  end
end
