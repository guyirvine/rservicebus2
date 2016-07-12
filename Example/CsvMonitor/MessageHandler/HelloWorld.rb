
class MessageHandler_HelloWorld

	attr_accessor :bus, :output_dir
    
	@OutputDir

    
	def handle( msg )
        	IO.write( @output_dir.path + '/output.txt', msg.payload.to_s )
	end
end
