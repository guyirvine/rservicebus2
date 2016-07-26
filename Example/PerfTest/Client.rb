$:.unshift './../../lib'

require 'rservicebus2'
require 'rservicebus2/Agent'
require './Contract'

ENV['RSBMQ'] = 'beanstalk://localhost'
agent = RServiceBus2::Agent.new

1.upto(10_000) do |request_nbr|
  agent.sendMsg(PerfTest.new('Hello World! ' + request_nbr.to_s), 'PerfTest')
end
