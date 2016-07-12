require 'parse-cron'

module RServiceBus
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
      fail NoMatchingMsgForCron, name if list.length == 0
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

    def initialize(host, msg_names = [])
      @bus = host
      @msg_names = msg_names

      RServiceBus.rlog 'Load Cron'
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

    def run
      now = Time.now
      @list.each_with_index do |v, idx|
        next if now <= v['next']

        RServiceBus.rlog "CronManager.Send, #{v['name']}"
        @bus.send(RServiceBus.create_anonymous_class(v['name']))
        @list[idx]['next'] = v['cron'].next(now)
      end
    end
  end
end
