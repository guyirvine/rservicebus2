$:.unshift './../../lib'
require 'rservicebus'
require 'rservicebus/Agent'
require './Contract'

ENV['RSBMQ'] = 'beanstalk://localhost'
agent = RServiceBus::Agent.new

1.upto(2) do |request_nbr|
	agent.send_msg(HelloWorld.new( 'Hello World! ' + request_nbr.to_s ), 'HelloWorld', 'helloResponse')
end

msg = agent.check_for_reply('helloResponse')
puts msg
msg = agent.check_for_reply( "helloResponse"  )
puts msg


