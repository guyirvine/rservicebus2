# frozen_string_literal: true

# Add the currently running directory to the start of the load path
# $:.unshift File.dirname(__FILE__) + '/../../lib'

# Don't buffer stdout
$stdout.sync = true

require 'rubygems'
require 'yaml'
require 'uuidtools'
require 'json'
require 'uri'

require 'rservicebus2/helper_functions'
require 'rservicebus2/errormessage'
require 'rservicebus2/handler_loader'
require 'rservicebus2/handler_manager'
require 'rservicebus2/appresource_configure'
require 'rservicebus2/mq'
require 'rservicebus2/host'
require 'rservicebus2/config'
require 'rservicebus2/endpointmapping'
require 'rservicebus2/stats'
require 'rservicebus2/statistic_manager'
require 'rservicebus2/audit'

require 'rservicebus2/message'
require 'rservicebus2/message/subscription'
require 'rservicebus2/message/statisticoutput'
require 'rservicebus2/message/verboseoutput'

require 'rservicebus2/usermessage/withpayload'

require 'rservicebus2/state_manager'
require 'rservicebus2/cron_manager'
require 'rservicebus2/circuitbreaker'

require 'rservicebus2/appresource'
require 'rservicebus2/resource_manager'

require 'rservicebus2/subscription_manager'
require 'rservicebus2/subscription_storage'
require 'rservicebus2/subscription_storage_configure'

require 'rservicebus2/monitor_configure'

require 'rservicebus2/agent'

require 'rservicebus2/saga_loader'
require 'rservicebus2/saga/manager'
require 'rservicebus2/saga/data'
require 'rservicebus2/saga/base'

require 'rservicebus2/saga_storage'

require 'rservicebus2/sendat_manager'

# Initial definition of the namespace
module RServiceBus2
end
