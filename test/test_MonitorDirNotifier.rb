require 'minitest/autorun'
require './lib/rservicebus2/Monitor/DirNotifier.rb'
require 'pathname'

# TestMonitorDirNotifier
class TestMonitorDirNotifier < RServiceBus2::MonitorDirNotifier
  attr_accessor :file_list

  def initialize
    @file_list = []
    super()
  end

  def file_writable?(_path)
    true
  end

  def open_folder(_path)
  end

  def move_file(src, dest)
    filename = Pathname.new(src).basename
    @file_list.delete src
    @file_list << Pathname.new(dest).join(filename)
    Pathname.new(dest).join(filename)
  end

  def get_files
    @file_list
  end

  def send(_payload, _uri)
  end
end

# DirNotifierTest
class DirNotifierTest < Minitest::Test
  def test_NoFilterDefined
    directory = '/tmp/incoming'
    processing_dir = '/tmp/processing'

    dir_notifier = TestMonitorDirNotifier.new
    dir_notifier.connect(URI("#{directory}?processing=#{processing_dir}"))
    assert_equal('*', dir_notifier.filter)
  end

  def test_SetsFilter
    directory = '/tmp/incoming'
    processing_dir = '/tmp/processing'
    filter = 'test.txt'

    dir_notifier = TestMonitorDirNotifier.new
    uri_string = "#{directory}?processing=#{processing_dir}&filter=#{filter}"
    dir_notifier.connect(URI(uri_string))

    assert_equal('test.txt', dir_notifier.filter)
  end
end
