require 'rservicebus/Monitor/Dir'
require 'csv'

module RServiceBus
  # Pull files and pre-parse as csv
  class MonitorCsvDir < MonitorDir
    def check_payload_for_number_of_columns(payload)
      return if @QueryStringParts.nil?
      return unless @QueryStringParts.key?('cols')

      cols = @QueryStringParts['cols'][0].to_i
      payload.each_with_index do |row, idx|
        if row.length != cols
          fail "Expected number of columns, #{cols}, Actual number of columns,
            #{row.length}, on line, #{idx}"
        end
      end
    end

    def check_send_hash
      if !@QueryStringParts.nil? && @QueryStringParts.key?('hash')
        flag = @QueryStringParts['hash'][0]
        return flag == 'Y'
      end

      false
    end

    def process_to_hash(p)
      headline = payload.shift
      payload = []
      p.each do |csvline|
        hash = {}
        csvline.each_with_index do |v, idx|
          hash[headline[idx]] = v
        end
        payload << hash
      end

      payload
    end

    def process_content(content)
      payload = CSV.parse(content)
      check_payload_for_number_of_columns(payload)

      payload = process_to_hash(payload) if check_send_hash

      payload
    end
  end
end
