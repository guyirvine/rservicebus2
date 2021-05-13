# frozen_string_literal: true

require 'rservicebus2/monitor/dir'
require 'xmlsimple'

module RServiceBus2
  # Monitor Dir for XML files
  class MonitorXmlDir < MonitorDir
    def process_content(content)
      XmlSimple.xml_in(content)
    end
  end
end
