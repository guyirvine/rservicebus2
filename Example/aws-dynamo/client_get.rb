$:.unshift './../../lib'
require 'rservicebus2'
require 'rservicebus2/agent'
require './contract'

ENV['RSBMQ'] = 'beanstalk://localhost'
agent = RServiceBus2::Agent.new

id = '5b33e2fa-dda6-4ec2-8956-52cbad47e32a';
agent.send_msg(TableGet.new(id), 'HelloWorld')
