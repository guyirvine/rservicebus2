$:.unshift './../../lib'

require 'redis'
require 'rservicebus2'

redis = Redis.new
require 'rservicebus2/Agent'
require './Contract'

ENV['RSBMQ'] = 'beanstalk://localhost'
agent = RServiceBus2::Agent.new

request_nbr = 1
redis.set 'key.' + request_nbr.to_s, 'BigBangTheory.' + request_nbr.to_s
agent.sendMsg(HelloWorld.new("key.#{request_nbr}"),
              'HelloWorld',
              'helloResponse')
