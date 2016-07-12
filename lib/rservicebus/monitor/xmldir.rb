require 'rservicebus/monitor/dir'
require 'xmlsimple'

module RServiceBus
  # Monitor Dir for XML files
  class MonitorXmlDir < MonitorDir
    def process_content(content)
      XmlSimple.xml_in(content)
    end
  end
end
