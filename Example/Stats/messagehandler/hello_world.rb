
class MessageHandlerHelloWorld

	attr_accessor :bus

	def handle( msg )
#raise "Manually generated error for testng"
		puts 'Handling Hello World: ' + msg.name
		@bus.reply( 'Hey. ' + msg.name )
	end
end
