class MessageHandlerPerfTest
  attr_accessor :Bus

  def initialize
    @count = 0
    @start = Time.now
  end

  def handle(_msg)
    @count += 1
    return if @count % 1000 != 0

    finish = Time.now
    elapsed = (finish - @start) * 1000
    puts "Done: #{elapsed}"
    @start = Time.now
  end
end
