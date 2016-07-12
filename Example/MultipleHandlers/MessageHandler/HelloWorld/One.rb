
class MessageHandler_HelloWorld_One

	attr_accessor :bus

	def handle( msg )
		puts 'MessageHandler_HelloWorld_One: HelloWorld'
		@bus.reply('Reply from MessageHandler_HelloWorld_One')
	end
end
