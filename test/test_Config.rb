require 'minitest/autorun'
require './lib/rservicebus2/Config.rb'

# TestConfig
class TestConfig < RServiceBus2::Config
  attr_reader :require_list

  def initialize
    @value_list = {}
    @require_list = []
  end

  def get_value(name, default = nil)
    (@value_list[name].nil? || @value_list[name] == '') ? default : @value_list[name]
  end

  def set_value(name, value)
    @value_list[name] = value
  end

  def log(_string)
  end

  def perform_require(path)
    @require_list << path
  end

  def ensure_contract_file_exists(_path)
  end
end

# ConfigTest
class ConfigTest < Minitest::Test
  def test_load_handler_path_list_nil
    config = TestConfig.new

    config.load_handler_path_list

    assert_equal 1, config.handler_path_list.length
    assert_equal './MessageHandler', config.handler_path_list[0]
  end

  def test_load_handler_path_list_empty
    config = TestConfig.new

    config.set_value('MSGHANDLERPATH', '')
    config.load_handler_path_list

    assert_equal 1, config.handler_path_list.length
    assert_equal './MessageHandler', config.handler_path_list[0]
  end

  def test_load_handler_path_list_single
    config = TestConfig.new

    config.set_value( 'MSGHANDLERPATH', '/path')
    config.load_handler_path_list

    assert_equal 1, config.handler_path_list.length
    assert_equal '/path', config.handler_path_list[0]
  end

  def test_load_handler_path_list_single_with_seperator
    config = TestConfig.new

    config.set_value('MSGHANDLERPATH', '/path;')
    config.load_handler_path_list

    assert_equal 1, config.handler_path_list.length
    assert_equal '/path', config.handler_path_list[0]
  end

  def test_load_handler_path_list_two
    config = TestConfig.new

    config.set_value('MSGHANDLERPATH', '/path1;/path2')
    config.load_handler_path_list

    assert_equal 2, config.handler_path_list.length
    assert_equal '/path1', config.handler_path_list[0]
    assert_equal '/path2', config.handler_path_list[1]
  end

  def test_load_handler_path_list_two_with_trailing_slash
    config = TestConfig.new

    config.set_value('MSGHANDLERPATH', '/path1/;/path2/')
    config.load_handler_path_list

    assert_equal 2, config.handler_path_list.length
    assert_equal '/path1', config.handler_path_list[0]
    assert_equal '/path2', config.handler_path_list[1]
  end

  def test_loadContracts_single
    config = TestConfig.new

    config.set_value('CONTRACTS', '/path')
    config.load_contracts

    assert_equal 1, config.contract_list.length
    assert_equal '/path', config.contract_list[0]
  end

  def test_loadContracts_single_with_seperator
    config = TestConfig.new

    config.set_value('CONTRACTS', '/path;')
    config.load_contracts

    assert_equal 1, config.contract_list.length
    assert_equal '/path', config.contract_list[0]
  end

  def test_loadContracts_two
    config = TestConfig.new

    config.set_value('CONTRACTS', '/path1;/path2')
    config.load_contracts

    assert_equal 2, config.contract_list.length
    assert_equal '/path1', config.contract_list[0]
    assert_equal '/path2', config.contract_list[1]
  end
end
