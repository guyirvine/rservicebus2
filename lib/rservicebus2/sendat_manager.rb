require 'rservicebus2/sendat_storage'

module RServiceBus2
  # Send At Manager
  class SendAtManager
    def initialize(bus)
      # Check if the SendAt Dir has been specified
      # If it has, make sure it exists, and is writable

      string = RServiceBus2.get_value('SENDAT_URI')
      string = 'file:///tmp/rservicebus-sendat' if string.nil?

      uri = URI.parse(string)
      @sendat_storage = SendAtStorage.get(uri)
      @bus = bus
    end

    def process
      now = DateTime.now
      @sendat_storage.get_all.each_with_index do |row, idx|
        next if row['timestamp'] <= now

        @bus._send_needs_wrapping(row['msg'], row['queue_name'],
                                  row['correlation_id'])
        @sendat_storage.delete(idx)
      end
    end

    def add(row)
      @sendat_storage.add(row)
    end
  end
end
