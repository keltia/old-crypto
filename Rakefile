# $Id: Rakefile,v f5cb85b76669 2011/08/11 14:30:56 roberto $
#
require 'rake'
require 'rake/testtask'

task :default => [:test_units]

desc "Run basic tests"
Rake::TestTask.new("test_units") { |t|
  t.pattern = 'test/**/*.rb'
  t.verbose = true
  t.warning = true
}

desc "Report code statistics (KLOCs, etc) from the application"
task :stats do
  require './rake/code_statistics'
  CodeStatistics.new(
    ["Code", "lib"],
    ["Units", "test"]
  ).to_s
end

desc "Cleanup files that are auto-generated"
task :clean do
  FileUtils.rm Dir.glob("**/*.rbc")
end

desc "Cleanup even more files"
task :realclean do
  FileUtils.rm Dir.glob("**/*.rej")
  FileUtils.rm Dir.glob("**/*.orig")
end

require './lib/old_crypto.rb'

