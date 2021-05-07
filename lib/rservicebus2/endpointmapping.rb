# frozen_string_literal: true

module RServiceBus2
  # Marshals data for message end points
  # Expected format: <msg mame 1>:<end point 1>;<msg mame 2>:<end point 2>
  class EndpointMapping
    def get_value(name)
      RServiceBus2.get_value(name)
    end

    def log(string, _ver: false)
      RServiceBus2.log(string)
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def configure_mapping(mapping)
      match = mapping.match(/(.+):(.+)/)
      if match.nil?
        log 'Mapping string provided is invalid\n' \
            "The entire mapping string is: #{mapping}\n" \
            "*** Could not find ':' in mapping entry, #{line}\n"
        exit
      end

      RServiceBus2.rlog "EndpointMapping.configureMapping: #{match[1]}, #{match[2]}"
      @endpoints[match[1]] = match[2]

      @queue_name_list.each do |q|
        next unless q != match[2] && q.downcase == match[2].downcase

        log('*** Two queues specified with only case sensitive difference.')
        log("*** #{q} != #{match[2]}")
        log('*** If you meant these queues to be the same, please match case
              and restart the bus.')
      end
      @queue_name_list << match[2]
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength
    def configure(local_queue_name = nil)
      log('EndpointMapping.Configure')

      @queue_name_list = []
      @queue_name_list << local_queue_name unless local_queue_name.nil?

      unless get_value('MESSAGE_ENDPOINT_MAPPING').nil?
        log '*** MESSAGE_ENDPOINT_MAPPING environment variable was detected\n' \
            "*** You may have intended MESSAGE_ENDPOINT_MAPPINGS, note the 'S'
              on the end"
      end

      mappings = get_value('MESSAGE_ENDPOINT_MAPPINGS')
      return self if mappings.nil?

      mappings.split(';').each do |mapping|
        configure_mapping(mapping)
      end

      self
    end
    # rubocop:enable Metrics/MethodLength

    def initialize
      @endpoints = {}
    end

    def get(msg_name)
      return @endpoints[msg_name] if @endpoints.key?(msg_name)

      nil
    end

    def subscription_endpoints
      @endpoints.keys.select { |el| el.end_with?('Event') }
    end
  end
end
