$:.unshift './../../lib'
require 'rservicebus'
require 'rservicebus/Agent'
require './Contract'

ENV['RSBMQ'] = 'beanstalk://localhost'
agent = RServiceBus::Agent.new

agent.send_msg(HelloWorld1.new('Hello World!'), 'HelloWorld', 'helloResponse')

