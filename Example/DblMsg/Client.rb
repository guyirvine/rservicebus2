$:.unshift './../../lib'
require 'rservicebus2'
require 'rservicebus2/Agent'
require './Contract'

ENV['RSBMQ'] = 'beanstalk://localhost'
agent = RServiceBus2::Agent.new

agent.send_msg(HelloWorld1.new('Hello World!'), 'HelloWorld', 'helloResponse')
