# frozen_string_literal: true

require 'parse-cron'

module RServiceBus2
  # Globber
  class Globber
    def self.parse_to_regex(str)
      escaped = Regexp.escape(str).gsub('\*', '.*?')
      Regexp.new "^#{escaped}$", Regexp::IGNORECASE
    end

    def initialize(str)
      @regex = self.class.parse_to_regex str
    end

    def =~(str)
      !!(str =~ @regex)
    end
  end

  class NoMatchingMsgForCron < StandardError
  end

  # Cron Manager
  class CronManager
    def get_matching_msg_names(name)
      list = []
      @msg_names.each do |n|
        list << n if Globber.new(name) =~ n
      end
      raise NoMatchingMsgForCron, name if list.empty?

      list
    end

    def add_cron(name, cron_string)
      get_matching_msg_names(name).each do |n|
        hash = {}
        hash['name'] = n
        hash['last'] = Time.now
        hash['v'] = cron_string
        hash['cron'] = CronParser.new(cron_string)
        hash['next'] = hash['cron'].next(Time.now)
        @list << hash
        @bus.log("Cron set for, #{n}, #{cron_string}, next run, #{hash['next']}")
      end
    end

    # rubocop:disable Metrics/MethodLength
    def initialize(host, msg_names = [])
      @bus = host
      @msg_names = msg_names

      RServiceBus2.rlog 'Load Cron'
      @list = []
      ENV.each do |k, vs|
        if k.start_with?('RSBCRON_')
          add_cron(k.sub('RSBCRON_', ''), vs)
        elsif k.start_with?('RSBCRON')
          vs.split(';').each do |v|
            parts = v.split(' ', 6)
            add_cron(parts.pop, parts.join(' '))
          end
        end
      end
    end
    # rubocop:enable Metrics/MethodLength

    def run
      now = Time.now
      @list.each_with_index do |v, idx|
        next if now <= v['next']

        RServiceBus2.rlog "CronManager.Send, #{v['name']}"
        @bus.send(RServiceBus2.create_anonymous_class(v['name']))
        @list[idx]['next'] = v['cron'].next(now)
      end
    end
  end
end
