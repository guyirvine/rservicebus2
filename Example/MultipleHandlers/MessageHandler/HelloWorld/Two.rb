
class MessageHandler_HelloWorld_Two

	attr_accessor :bus
	@bus

	def handle( msg )
		puts 'MessageHandler_HelloWorld_Two: HelloWorld'
		@bus.reply('Reply from MessageHandler_HelloWorld_Two')
	end
end
