$:.unshift './../../lib'
require 'rservicebus'
require 'rservicebus/Agent'
require './Contract'

ENV['MESSAGE_ENDPOINT_MAPPINGS']='HelloWorld:HelloWorld'
ENV['AUDIT_QUEUE_NAME']='ClientAudit'

1.upto(2) do |request_nbr|
	RServiceBus.send_msg( HelloWorld.new( 'Hello World! ' + request_nbr.to_s ), 'helloResponse')
end

msg = RServiceBus.check_for_reply('helloResponse')
puts msg
msg = RServiceBus.check_for_reply('helloResponse')
puts msg


