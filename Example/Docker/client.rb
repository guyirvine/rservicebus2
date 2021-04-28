$:.unshift './../../lib'
require 'rservicebus2'
require 'rservicebus2/agent'
require './contract'

ENV['RSBMQ'] = 'beanstalk://localhost'
agent = RServiceBus2::Agent.new

1.upto(2) do |request_nbr|
  agent.send_msg(HelloWorld.new('Hello World! ' + request_nbr.to_s),
                 'Project',
                 'projectResponse')
end

msg = agent.check_for_reply('projectResponse')
puts msg
msg = agent.check_for_reply('projectResponse')
puts msg
