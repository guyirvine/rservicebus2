$:.unshift './../../lib'

require 'rservicebus2'
require 'rservicebus2/agent'
require './contract'

ENV['RSBMQ'] = 'beanstalk://localhost'
agent = RServiceBus2::Agent.new

agent.send_msg(HelloWorld.new('Hello World!'),
               'HelloWorldMultiple',
               'helloWorldMultipleResponse')

puts agent.check_for_reply('helloWorldMultipleResponse')
puts agent.check_for_reply('helloWorldMultipleResponse')
