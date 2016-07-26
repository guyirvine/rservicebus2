$:.unshift './../../lib'
require 'rservicebus2'
require 'rservicebus2/Agent'
require './Contract'

agent = RServiceBus2::Agent.new.getAgent( URI.parse('beanstalk://localhost') )

agent.sendMsg(RServiceBus2::Message_StatisticOutputOn.new, 'HelloWorld', 'helloResponse')
