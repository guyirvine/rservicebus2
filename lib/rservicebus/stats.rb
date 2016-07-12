module RServiceBus
  # Used to collect various run time stats for runtime reporting
  class Stats
    def initialize
      @hash = {}

      @total_processed = 0
      @total_errored = 0
      @total_sent = 0
      @total_published = 0
      @total_reply = 0

      @total_by_message_type = {}

      @written = false
    end

    def inc_total_processed
      @total_processed += 1
    end

    def inc_total_errored
      @total_errored += 1
    end

    def inc_total_sent
      @total_sent += 1
    end

    def inc_total_published
      @total_published += 1
    end

    def inc_total_reply
      @total_reply += 1
    end

    def inc(key)
      @hash[key] = 0 if @hash[key].nil?
      @hash[key] += 1
    end

    def inc_message_type(class_name)
      @total_by_message_type[class_name] = 0 if @total_by_message_type[class_name].nil?
      @total_by_message_type[class_name] += 1
    end
  end

  def get_for_reporting_2
    return unless @written == false

    @written = true
    types = Hash.new(0)
    ObjectSpace.each_object do |obj|
      types[obj.class] += 1
    end

    types
  end

  def get_for_reporting
    "T:#{@total_processed};
     E:#{@total_errored};
     S:#{@total_sent};
     P:#{@total_published};
     R:#{@total_reply}"
  end
end
