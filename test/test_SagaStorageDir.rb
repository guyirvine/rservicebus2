require 'minitest/autorun'

require './lib/rservicebus2/saga/Base.rb'
require './lib/rservicebus2/saga/manager.rb'
require './lib/rservicebus2/message.rb'
require './lib/rservicebus2/saga/data.rb'
require './lib/rservicebus2/resource_manager.rb'

require 'rservicebus2/saga_storage/inmemory.rb'
require 'rservicebus2/saga_storage/dir.rb'

require './lib/rservicebus2/Test/Bus'

# Msg1
class Msg1
  attr_accessor :field1

  def initialize(field1)
    @field1 = field1
  end
end

# Msg2
class Msg2
  attr_reader :field2, :field3

  def initialize(field2, field3)
    @field2 = field2
    @field3 = field3
  end
end

# Msg3
class Msg3
  attr_accessor :field1

  def initialize(field1)
    @field1 = field1
  end
end

# SagaMsg1Msg2
class SagaMsg1Msg2 < RServiceBus2::SagaBase
  def startwith_Msg1(msg)
    @data['Bob1'] = 'John1'
    @data['sfield2'] = msg.field1
  end

  def handle_msg2(msg)
    @data['Bob1'] = msg.field2
    @data['Bob2'] = msg.field2
  end

  def handle_msg3(_msg)
    finish
  end
end

# Saga_Manager_For_Testing
class SagaManagerForTesting < RServiceBus2::SagaManager
  attr_reader :correlation_id
end

# SagaStorageDirForTesting
class SagaStorageDirForTesting < RServiceBus2::SagaStorageDir
  attr_reader :list

  def correlation_id_for_first_saga
    @list[0]['data'].correlation_id
  end

  def data_for_first_saga
    get(@list[0]['data'].correlation_id)
  end
end

# ResourceManagerForTestingSagas
class ResourceManagerForTestingSagas < RServiceBus2::ResourceManager
end

# SagaStorageDirTest
class SagaStorageDirTest < Minitest::Test
  def setup
    Dir.glob('/tmp/saga-*').each do |path|
      File.unlink(path)
    end

    @bus = RServiceBus2::TestBus.new

    @saga_storage = SagaStorageDirForTesting.new(URI.parse('dir:///tmp/'))
    @resource_manager = ResourceManagerForTestingSagas.new(nil, @saga_storage)
    @saga_manager = SagaManagerForTesting.new(@bus,
                                              @resource_manager,
                                              @saga_storage)
    @msg1 = RServiceBus2::Message.new(Msg1.new('One'), 'Q')

    @saga_storage.begin
  end

  def test_StartSaga
    assert_equal 0, Dir.glob('/tmp/saga-*').length

    @saga_manager.register_saga(SagaMsg1Msg2)
    @saga_manager.handle(@msg1)
    assert_equal 1, @saga_storage.list.length
    data = @saga_storage.list[0]['data']

    assert_equal 0, Dir.glob('/tmp/saga-*').length
    @saga_storage.commit
    assert_equal 1, Dir.glob('/tmp/saga-*').length
    assert_equal true, File.exist?("/tmp/saga-#{data.correlation_id}")

    stored_data = @saga_storage.get(data.correlation_id)
    assert_equal 'John1', stored_data['Bob1']
    assert_equal 'One', stored_data['sfield2']
  end

  def test_SagaWithFollowUpMsg
    @saga_manager.register_saga(SagaMsg1Msg2)
    assert_equal 0, Dir.glob('/tmp/saga-*').length

    @saga_manager.handle(@msg1)
    @saga_storage.commit
    assert_equal 1, Dir.glob('/tmp/saga-*').length
    data = @saga_storage.data_for_first_saga
    correlation_id = data.correlation_id
    assert_equal 'John1', data['Bob1']
    assert_equal 'One', data['sfield2']

    msg2 = RServiceBus2::Message.new(Msg2.new('BB', 'AA'),
                                     'Q',
                                     correlation_id)
    @saga_manager.handle(msg2)
    @saga_storage.commit
    assert_equal 1, Dir.glob('/tmp/saga-*').length
    data = @saga_storage.data_for_first_saga
    assert_equal 'BB', data['Bob1']
    assert_equal 'BB', data['Bob2']
    assert_equal 'One', data['sfield2']
  end

  def test_SagaWithFollowUpMsgAndFinish
    @saga_manager.register_saga(SagaMsg1Msg2)
    assert_equal 0, Dir.glob('/tmp/saga-*').length

    @saga_manager.handle(@msg1)
    @saga_storage.commit
    assert_equal 1, Dir.glob('/tmp/saga-*').length
    data = @saga_storage.data_for_first_saga
    correlation_id = data.correlation_id
    assert_equal 'John1', data['Bob1']
    assert_equal 'One', data['sfield2']

    msg2 = RServiceBus2::Message.new(Msg2.new('BB', 'AA'),
                                     'Q',
                                     correlation_id)
    @saga_manager.handle(msg2)
    @saga_storage.commit
    assert_equal 1, Dir.glob('/tmp/saga-*').length
    data = @saga_storage.data_for_first_saga
    assert_equal 'BB', data['Bob1']
    assert_equal 'BB', data['Bob2']
    assert_equal 'One', data['sfield2']

    msg3 = RServiceBus2::Message.new(Msg3.new('CC'),
                                     'Q',
                                     correlation_id)
    @saga_manager.handle(msg3)
    @saga_storage.commit
    assert_equal 0, Dir.glob('/tmp/saga-*').length
  end
end
