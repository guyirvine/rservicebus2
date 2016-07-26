require 'minitest/autorun'
require './lib/rservicebus2/saga_storage.rb'
require './lib/rservicebus2/state_manager.rb'
require './lib/rservicebus2/appresource.rb'

require './lib/rservicebus2/resource_manager.rb'

# TestResourceManager
class TestResourceManager < RServiceBus2::ResourceManager
end

# TestResource
class TestResource
  attr_reader :string, :close_called, :commit_called, :rollback_called

  def initialize(string)
    @string = string
    @close_called = false
    @commit_called = false
  end

  def close
    @close_called = true
  end

  def commit
    @commit_called = true
  end

  def rollback
    @rollback_called = true
  end
end

# TestAppResource
class TestAppResource < RServiceBus2::AppResource
  attr_reader :r
  def connect(uri)
    @r = TestResource.new(uri)
  end

  def commit
    @r.commit
  end

  def rollback
    @r.rollback
  end
end

# ResourceManagerTest
class ResourceManagerTest < Minitest::Test
  def setup
    ENV['SAGA_URI'] = 'immem://'
    @sa = RServiceBus2::SagaStorage.get(URI.parse('inmem://path'))

    ENV['STATE_URI'] = 'immem://'
    @st = RServiceBus2::StateManager.new
    @r = RServiceBus2::ResourceManager.new(@st, @sa)
  end

  def test_GetAll
    @r.add('one', 'one')
    @r.add('two', 'two')

    assert_equal Hash['one', 'one', 'two', 'two'], @r.get_all
  end

  def test_Get
    ta_before = TestAppResource.new(nil, nil)

    @r.add('test', ta_before)

    ta_after = @r.get('test')
    assert_equal 'TestAppResource', ta_after.class.name
  end

  def test_Commit
    ta_before = TestAppResource.new(nil, nil)

    @r.add('test', ta_before)

    @r.begin
    ta_after = @r.get('test')
    tr = ta_after.r
    assert_equal 'TestResource', tr.class.name
    assert_equal false, tr.commit_called

    @r.commit('MsgName')
    assert_equal 'TestAppResource', ta_after.class.name
    assert_equal true, tr.commit_called
  end

  def test_Rollback
    ta_before = TestAppResource.new(nil, nil)

    @r.add('test', ta_before)

    @r.begin
    ta_after = @r.get('test')
    tr = ta_after.r
    assert_equal 'TestResource', tr.class.name
    assert_equal false, tr.commit_called

    @r.rollback('MsgName')
    assert_equal 'TestAppResource', ta_after.class.name
    assert_equal false, tr.commit_called
    assert_equal true, tr.rollback_called
  end
end
