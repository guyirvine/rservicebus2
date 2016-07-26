$:.unshift './../../lib'
require 'rservicebus2'
require 'rservicebus2/Agent'
require './Contract'

ENV['RSBMQ'] = 'beanstalk://localhost'
agent = RServiceBus2::Agent.new

agent.sendMsg(Msg1.new('1'), 'Saga', 'helloResponse')
