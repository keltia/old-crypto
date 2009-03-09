# $Id: Rakefile,v ce951ed43ef0 2009/03/09 21:26:02 roberto $
#
require 'rake'
require 'rake/testtask'

task :default => [:test_units]

desc "Run basic tests"
Rake::TestTask.new("test_units") { |t|
  t.pattern = 'test/test_*.rb'
  t.verbose = true
  t.warning = true
}

desc "Report code statistics (KLOCs, etc) from the application"
task :stats do
  require 'rake/code_statistics'
  CodeStatistics.new(
    ["Code", "lib"],
    ["Units", "test"]
  ).to_s
end

