require 'minitest/autorun'
require './lib/rservicebus2/EndpointMapping.rb'

# TestEndpointMapping
class TestEndpointMapping<RServiceBus2::EndpointMapping
  attr_reader :endpoints
  def initialize
    super
    @value_list = {}
  end

  def get_value(name, default = nil)
    (@value_list[name].nil? || @value_list[name] == '') ? default : @value_list[name]
  end

  def set_value(name, value)
    @value_list[name] = value
  end

  def log(_string, _ver = false)
  end
end

# EndpointMappingTest
class EndpointMappingTest < Minitest::Test
  def test_loadMessageEndpointMappings_empty
    config = TestEndpointMapping.new

    config.set_value('MESSAGE_ENDPOINT_MAPPINGS', '')
    config.configure('localQueueName')

    assert_equal 0, config.endpoints.length
  end

  def test_loadMessageEndpointMappings_single_without_seperator
    config = TestEndpointMapping.new

    config.set_value('MESSAGE_ENDPOINT_MAPPINGS', 'msg:endpoint')
    config.configure('localQueueName')

    assert_equal 1, config.endpoints.length
    assert_equal 'endpoint', config.endpoints['msg']
  end

  def test_loadMessageEndpointMappings_single_with_seperator
    config = TestEndpointMapping.new

    config.set_value('MESSAGE_ENDPOINT_MAPPINGS', 'msg:endpoint;')
    config.configure('localQueueName')

    assert_equal 1, config.endpoints.length
    assert_equal 'endpoint', config.endpoints['msg']
  end

  def test_loadMessageEndpointMappings_two
    config = TestEndpointMapping.new

    config.set_value('MESSAGE_ENDPOINT_MAPPINGS',
                     'msg1:endpoint1;msg2:endpoint2')
    config.configure('localQueueName')

    assert_equal 2, config.endpoints.length
    assert_equal 'endpoint1', config.endpoints['msg1']
    assert_equal 'endpoint2', config.endpoints['msg2']
  end
end
