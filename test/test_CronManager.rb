require 'minitest/autorun'
require './lib/rservicebus2/cron_manager.rb'
require './Mock/Host.rb'

# TestCronManager
class TestCronManager < RServiceBus2::CronManager
  attr_accessor :list
end

# CronManagerTest
class CronManagerTest < Minitest::Test
  def test_MultipleCronEntries
		ENV.delete('RSBCRON_Task3')
    ENV['RSBCRON'] = '1 * * * * Task1;* 3 * * * Task2'
    cron = TestCronManager.new(RServiceBus2::MockHost.new, %w(Task1 Task2))

    assert_equal 2, cron.list.length
    assert_equal 'Task1', cron.list[0]['name']
    assert_equal '1 * * * *', cron.list[0]['v']
    assert_equal 'Task2', cron.list[1]['name']
  end

  def test_MultipleCronEntriesAndASingle
    ENV['RSBCRON'] = '1 * * * * Task1;* 3 * * * Task2'
		ENV['RSBCRON_Task3'] = '4 * * * *'
    cron = TestCronManager.new(RServiceBus2::MockHost.new,
                               %w(Task3 Task2 Task1))

    assert_equal 3, cron.list.length
    assert_equal 'Task1', cron.list[0]['name']
    assert_equal '1 * * * *', cron.list[0]['v']
    assert_equal 'Task2', cron.list[1]['name']
    assert_equal 'Task3', cron.list[2]['name']

  end

  def test_CronMatchEntries
		ENV.delete('RSBCRON_Task3')
    ENV['RSBCRON'] = '1 * * * * Task*'
    cron = TestCronManager.new(RServiceBus2::MockHost.new, %w(Task1 Task2))

    assert_equal 2, cron.list.length
    assert_equal 'Task1', cron.list[0]['name']
    assert_equal '1 * * * *', cron.list[0]['v']
    assert_equal 'Task2', cron.list[1]['name']
  end
end
