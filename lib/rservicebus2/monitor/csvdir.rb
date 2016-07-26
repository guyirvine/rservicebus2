require 'rservicebus2/Monitor/Dir'
require 'csv'

module RServiceBus2
  # Pull files and pre-parse as csv
  class MonitorCsvDir < MonitorDir
    def check_payload_for_number_of_columns(payload)
      return if @query_string_parts.nil?
      return unless @query_string_parts.key?('cols')

      cols = @query_string_parts['cols'][0].to_i
      payload.each_with_index do |row, idx|
        if row.length != cols
          fail "Expected number of columns, #{cols}, Actual number of columns,
            #{row.length}, on line, #{idx}"
        end
      end
    end

    def check_send_hash
      if !@query_string_parts.nil? && @query_string_parts.key?('hash')
        flag = @query_string_parts['hash'][0]
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
