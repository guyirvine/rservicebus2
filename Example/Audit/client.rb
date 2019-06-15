$:.unshift './../../lib'
require 'rservicebus2'
require 'rservicebus2/agent'
require './contract'

ENV['MESSAGE_ENDPOINT_MAPPINGS'] = 'HelloWorld:HelloWorld'
ENV['AUDIT_QUEUE_NAME'] = 'ClientAudit'

1.upto(2) do |request_nbr|
  RServiceBus2.send_msg(HelloWorld.new('Hello World! ' + request_nbr.to_s),
                        'helloResponse')
end

msg = RServiceBus2.check_for_reply('helloResponse')
puts msg
msg = RServiceBus2.check_for_reply('helloResponse')
puts msg
