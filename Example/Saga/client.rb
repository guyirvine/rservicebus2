$:.unshift './../../lib'
require 'rservicebus2'
require 'rservicebus2/agent'
require './contract'

ENV['RSBMQ'] = 'beanstalk://localhost'
agent = RServiceBus2::Agent.new

# ['A', 'B', 'C'].each do |el|
  el = 'a'
  agent.send_msg(Msg1.new("#{el}: 1"), 'Saga', 'helloResponse')
# end
