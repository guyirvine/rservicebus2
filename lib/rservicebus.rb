# Add the currently running directory to the start of the load path
# $:.unshift File.dirname(__FILE__) + '/../../lib'

# Don't buffer stdout
$stdout.sync = true

require 'rubygems'
require 'yaml'
require 'uuidtools'
require 'json'
require 'uri'

require 'rservicebus/helper_functions'
require 'rservicebus/errormessage'
require 'rservicebus/handler_loader'
require 'rservicebus/handler_manager'
require 'rservicebus/appresource_configure'
require 'rservicebus/mq'
require 'rservicebus/host'
require 'rservicebus/config'
require 'rservicebus/endpointmapping'
require 'rservicebus/stats'
require 'rservicebus/statistic_manager'
require 'rservicebus/audit'

require 'rservicebus/message'
require 'rservicebus/message/subscription'
require 'rservicebus/message/statisticoutput'
require 'rservicebus/message/verboseoutput'

require 'rservicebus/usermessage/withpayload'

require 'rservicebus/state_manager'
require 'rservicebus/cron_manager'
require 'rservicebus/circuitbreaker'

require 'rservicebus/appresource'
require 'rservicebus/resource_manager'

require 'rservicebus/subscription_manager'
require 'rservicebus/subscription_storage'
require 'rservicebus/subscription_storage_configure'

require 'rservicebus/monitor_configure'

require 'rservicebus/agent'

require 'rservicebus/saga_loader.rb'
require 'rservicebus/saga/manager.rb'
require 'rservicebus/saga/data.rb'
require 'rservicebus/saga/base.rb'

require 'rservicebus/saga_storage'

require 'rservicebus/sendat_manager'

# Initial definition of the namespace
module RServiceBus
end
