# $Id: Rakefile,v 8cb890021e66 2009/02/19 14:55:42 roberto $
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
    ["Code", "."],
    ["Units", "test"]
  ).to_s
end

