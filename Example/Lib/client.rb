$:.unshift './../../lib'
require 'rservicebus2'
require 'rservicebus2/agent'
require './contract'

ENV['RSBMQ'] = 'beanstalk://localhost'
agent = RServiceBus2::Agent.new

agent.send_msg(HelloWorld.new('Hello World!'), 'HelloWorld', 'helloResponse')

msg = agent.check_for_reply('helloResponse')
puts msg
