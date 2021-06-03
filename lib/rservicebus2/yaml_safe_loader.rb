# frozen_string_literal: true

require 'csv'
require 'singleton'

# YamlSafeLoader
class YamlSafeLoader
  include Singleton

  DEFAULT_PERMITTED_CLASSES = 'RServiceBus2::Message,RServiceBus2::ErrorMessage,Time,UUIDTools::UUID,YamlSafeLoader,' \
                              'URI::Generic,URI::RFC3986_Parser,Symbol,Regexp'

  def initialize
    string = "#{RServiceBus2.get_value('PERMITTED_CLASSES_BASE', DEFAULT_PERMITTED_CLASSES)}," \
             "#{RServiceBus2.get_value('PERMITTED_CLASSES', '')}"
    @permitted_classes = CSV.parse(string)[0].reject { |c| c.to_s.rstrip.empty? }
  end

  def add_permitted_class(string)
    @permitted_classes << string
    @permitted_classes.uniq!
  end

  def load(body)
    YAML.safe_load(body, permitted_classes: @permitted_classes)
  end
end
