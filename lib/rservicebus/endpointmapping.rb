module RServiceBus
  # Marshals data for message end points
  # Expected format: <msg mame 1>:<end point 1>;<msg mame 2>:<end point 2>
  class EndpointMapping
    def get_value(name)
      RServiceBus.get_value(name)
    end

    def log(string, _ver = false)
      RServiceBus.log(string)
    end

    def configure_mapping(mapping)
      match = mapping.match(/(.+):(.+)/)
      if match.nil?
        log 'Mapping string provided is invalid'
        log "The entire mapping string is: #{mapping}"
        log "*** Could not find ':' in mapping entry, #{line}"
        exit
      end

      RServiceBus.rlog "EndpointMapping.configureMapping: #{match[1]}, #{match[2]}"
      @endpoints[match[1]] = match[2]

      @queue_name_list.each do |q|
        if q != match[2] && q.downcase == match[2].downcase
          log('*** Two queues specified with only case sensitive difference.')
          log("*** #{q} != #{match[2]}")
          log('*** If you meant these queues to be the same, please match case
                and restart the bus.')
        end
      end
      @queue_name_list << match[2]
    end

    def configure(local_queue_name=nil)
      log('EndpointMapping.Configure')

      @queue_name_list = []
      @queue_name_list << local_queue_name unless local_queue_name.nil?

      unless get_value('MESSAGE_ENDPOINT_MAPPING').nil?
        log('*** MESSAGE_ENDPOINT_MAPPING environment variable was detected')
        log("*** You may have intended MESSAGE_ENDPOINT_MAPPINGS, note the 'S'
              on the end")
      end

      mappings = get_value('MESSAGE_ENDPOINT_MAPPINGS')
      return self if mappings.nil?

      mappings.split(';').each do |mapping|
        configure_mapping(mapping)
      end

      self
    end

    def initialize
      @endpoints = {}
    end

    def get(msg_name)
      return @endpoints[msg_name] if @endpoints.key?(msg_name)

      nil
    end

    def get_subscription_endpoints
      @endpoints.keys.select { |el| el.end_with?('Event') }
    end
  end
end
