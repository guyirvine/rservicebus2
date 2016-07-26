$:.unshift './../../lib'
require 'rservicebus2'
require 'rservicebus2/Agent'
require './Contract'

ENV['RSBMQ'] = 'beanstalk://localhost'
agent = RServiceBus2::Agent.new

1.upto(2) do |request_nbr|
  agent.sendMsg(HelloWorld.new('Hello World! ' + request_nbr.to_s),
                'HelloWorld',
                'helloResponse')
end

msg = agent.checkForReply('helloResponse')
puts msg
msg = agent.checkForReply('helloResponse')
puts msg
