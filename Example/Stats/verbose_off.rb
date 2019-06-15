$:.unshift './../../lib'
require 'rservicebus2'
require 'rservicebus2/agent'
require './contract'

agent = RServiceBus2::Agent.new.get_agent( URI.parse('beanstalk://localhost') )

agent.send_msg(RServiceBus2::MessageVerboseOutputOff.new, 'HelloWorld', 'helloResponse')
