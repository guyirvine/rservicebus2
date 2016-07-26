require 'minitest/autorun'

require './lib/rservicebus2/saga/base.rb'
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
  def startwith_msg1(msg)
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

# SagaManagerForTesting
class SagaManagerForTesting < RServiceBus2::SagaManager
  attr_reader :correlation, :resourceManager
end

# SagaStorageInMemoryForTesting
class SagaStorageInMemoryForTesting < RServiceBus2::SagaStorageInMemory
  attr_reader :hash
end

# ResourceManagerForTestingSagas
class ResourceManagerForTestingSagas < RServiceBus2::ResourceManager
end

# SagaTest
class SagaTest < Minitest::Test
  def setup
    @bus = RServiceBus2::TestBus.new

    @saga_storage = SagaStorageInMemoryForTesting.new('')
    @resource_manager = ResourceManagerForTestingSagas.new(nil, @saga_storage)
    @saga_manager = SagaManagerForTesting.new(@bus,
                                              @resource_manager,
                                              @saga_storage)
    @msg1 = RServiceBus2::Message.new(Msg1.new('One'), 'Q')

    @saga_storage.begin
  end

  def test_SagaMsgDerivation
    assert_equal ['msg1'], @saga_manager.get_start_with_method_names(SagaMsg1Msg2)
  end

  def test_StartSaga
    @saga_manager.register_saga(SagaMsg1Msg2)

    assert_equal 0, @saga_storage.hash.keys.length
    @saga_manager.handle(@msg1)
    assert_equal 1, @saga_storage.hash.keys.length

    data = @saga_storage.hash[@saga_storage.hash.keys[0]]
    assert_equal 2, data.length

    data = @saga_storage.hash[@saga_storage.hash.keys[0]]
    assert_equal 2, data.length

    assert_equal 'John1', data['Bob1']
    assert_equal 'One', data['sfield2']
  end

  def test_SagaWithFollowUpMsg
    @saga_manager.register_saga(SagaMsg1Msg2)

    @saga_manager.handle(@msg1)
    assert_equal 1, @saga_storage.hash.keys.length

    msg2 = RServiceBus2::Message.new(Msg2.new('BB', 'AA'),
                                     'Q',
                                     @saga_storage.hash.keys[0])
    @saga_manager.handle(msg2)

    data = @saga_storage.hash[@saga_storage.hash.keys[0]]
    assert_equal 3, data.length

    assert_equal 'BB', data['Bob1']
    assert_equal 'BB', data['Bob2']
    assert_equal 'One', data['sfield2']
  end

  def test_SagaWithFollowUpMsgAndFinish
    @saga_manager.register_saga(SagaMsg1Msg2)

    @saga_manager.handle(@msg1)
    assert_equal 1, @saga_storage.hash.keys.length

    msg2 = RServiceBus2::Message.new(Msg2.new('BB', 'AA'),
                                     'Q',
                                     @saga_storage.hash.keys[0])
    @saga_manager.handle(msg2)
    assert_equal 3, @saga_storage.hash[@saga_storage.hash.keys[0]].length

    msg3 = RServiceBus2::Message.new(Msg3.new('CC'),
                                     'Q',
                                     @saga_storage.hash.keys[0])

    @saga_manager.handle(msg3)

    @saga_storage.commit
    assert_equal 1, @saga_storage.hash.length
  end
end
