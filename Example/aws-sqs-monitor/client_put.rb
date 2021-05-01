$:.unshift './../../lib'
require 'rservicebus2'
require 'rservicebus2/agent'
require './contract'

ENV['RSBMQ'] = 'beanstalk://localhost'
agent = RServiceBus2::Agent.new

seq = Time.now.strftime('%Y%m%d%H%M%S')
body = "body-#{seq}"
agent.send_msg(SqsPut.new(body), 'HelloWorld')
