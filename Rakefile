require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

task :build do
  `gem build rservicebus2.gemspec`
end

task :install do
  Rake::Task['build'].invoke
  cmd = "sudo gem install ./#{Dir.glob('rservicebus*.gem').sort.pop}"
  p "cmd: #{cmd}"
  `#{cmd}`
  p "gem push ./#{Dir.glob('rservicebus*.gem').sort.pop}"
end

desc 'Run tests'
task :default => :install
