$:.unshift './../../lib'
require 'rservicebus2'
require 'rservicebus2/Agent'
require './Contract'

ENV['RSBMQ'] = 'beanstalk://localhost'
agent = RServiceBus2::Agent.new

1.upto(2) do |request_nbr|
	agent.sendMsg(HelloWorld.new, 'State', 'stateResponse')
end
