Gem::Specification.new do |s|
  s.name        = 'rservicebus2'
  s.version     = '0.0.9'
  s.date        = '2016-08-01'
  s.summary     = "RServiceBus"
  s.description = "A Ruby interpretation of NServiceBus"
  s.authors     = ["Guy Irvine"]
  s.email       = 'guy@guyirvine.com'
  s.files       = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  s.homepage    = 'http://rubygems.org/gems/rservicebus2'
  s.license     = 'LGPL-3.0'
  s.add_dependency( "uuidtools" )
  s.add_dependency( "json" )
  s.add_dependency( "beanstalk-client" )
  s.add_dependency( "fluiddb" )
  s.add_dependency( "parse-cron" )
  s.executables << 'rservicebus2'
  s.executables << 'rservicebus2-init'
  s.executables << 'return_messages_to_source_queue'
  s.executables << 'send_empty_message'
  s.executables << 'rservicebus2-transport'
  s.executables << 'rservicebus2-create'
end
