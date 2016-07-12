
class MessageHandler_HelloWorld1

	attr_accessor :bus

	def handle( msg )
		puts 'Handling Hello World1: ' + msg.name
		@bus.send( HelloWorld2.new( 'Hey. ' + msg.name ) )
	end
end
