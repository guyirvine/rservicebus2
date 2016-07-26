class MessageHandler_HelloWorld
  attr_accessor :bus, :testsmbfile

  def handle(_msg)
    puts 'TestSmbFile: '
    size = @testsmbfile.stat.size
    buffer = @testsmbfile.read(size)
    puts "buffer: #{buffer}"
  end
end
