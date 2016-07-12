$:.unshift './../../lib'

require 'rservicebus'
require 'rservicebus/Agent'
require './Contract'

ENV['RSBMQ'] = 'beanstalk://localhost'
agent = RServiceBus::Agent.new

agent.send_msg(HelloWorld.new('Hello World!'), 'HelloWorldMultiple', 'helloWorldMultipleResponse')

puts agent.check_for_reply('helloWorldMultipleResponse')
puts agent.check_for_reply('helloWorldMultipleResponse')
