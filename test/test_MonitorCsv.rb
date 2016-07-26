require 'minitest/autorun'
require './lib/rservicebus2/monitor/csvdir.rb'

# TestMonitorCsvDir
class TestMonitorCsvDir < RServiceBus2::MonitorCsvDir
  def set_cols(cols)
    @query_string_parts = Hash['cols', [cols]]
  end
end

# ConfigTest
class ConfigTest < Minitest::Test
  def test_CheckNumberOfColumnsWithOneRowCorrectNumberOfColumns
    m = TestMonitorCsvDir.new
    m.set_cols(2)

    m.process_content('1, 2')
  end

  def test_CheckNumberOfColumnsOneRowIncorrectNumberOfColumns
    m = TestMonitorCsvDir.new
    m.set_cols(2)

    error_raised = false
    begin
      m.process_content('1, 2, 3')
    rescue
      error_raised = true
    end
    assert_equal true, error_raised
  end

  def test_CheckNumberOfColumnsMultipleRowsCorrectNumberOfColumns
    m = TestMonitorCsvDir.new
    m.set_cols(2)

    m.process_content("1, 2\n3, 4\n5, 6")
  end

  def test_CheckNumberOfColumnsMultipleRowsIncorrectNumberOfColumns
    m = TestMonitorCsvDir.new
    m.set_cols(2)

    error_raised = false
    begin
      m.process_content("1, 2\n3, 4, 8\n5, 6")
    rescue
      error_raised = true
    end
    assert_equal true, error_raised
  end

  def test_CheckNumberOfColumnsMultipleRows
    m = TestMonitorCsvDir.new
    m.set_cols(2)

    m.process_content("1, 2\n3, 4\n5, 6\n")
  end
end
