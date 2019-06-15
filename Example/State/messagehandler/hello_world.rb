
class MessageHandlerHelloWorld

	attr_accessor :bus, :state

	def handle( msg )
#raise "Manually generated error for testng"
		count = @state['count'] || 0
		count = count + 1
		puts "count: #{count}"
		@state['count'] = count
		puts 'Handling Msg'
	end
end


