Gem::Specification.new do |s|
  s.name        = 'rservicebus2'
  s.version     = '0.2.6'
  s.date        = '2021-04-28'
  s.summary     = "RServiceBus"
  s.description = "A Ruby interpretation of NServiceBus"
  s.authors     = ["Guy Irvine"]
  s.email       = 'guy@guyirvine.com'
  s.files       = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  s.homepage    = 'http://rubygems.org/gems/rservicebus2'
  s.license     = 'LGPL-3.0'

  s.add_dependency( "uuidtools", "~> 2.2.0" )
  s.add_dependency( "json", "~> 2.5.1" )
  s.add_dependency( "beanstalk-client", "~> 1.1.1" )
  s.add_dependency( "fluiddb", "~> 0.1.19" )
  s.add_dependency( "parse-cron", "~> 0.1.4" )

  s.executables << 'rservicebus2'
  s.executables << 'rservicebus2-init'
  s.executables << 'return_messages_to_source_queue'
  s.executables << 'send_empty_message'
  s.executables << 'rservicebus2-transport'
  s.executables << 'rservicebus2-create'
end
