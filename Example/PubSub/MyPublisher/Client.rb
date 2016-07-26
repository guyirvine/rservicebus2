require './rservicebus2'
require './Contract'

abort('Usage: RServiceBus2 [config file name]') if ARGV.length > 1

config_file_path = ARGV.length == 0 ? nil : ARGV[0]

bus = RServiceBus2::Host.new(config_file_path).loadHandlers
                                              .loadSubscriptions
                                              .sendSubscriptions

1.upto(1) do |request_nbr|
  bus.publish(HelloWorldEvent.new("Hello World: #{request_nbr}"))
end
