# $Id: Rakefile,v b644908571bf 2011/08/11 14:39:32 roberto $
#
require 'rake'
require 'rake/testtask'

task :default => [:test_units]

desc "Run basic tests"
Rake::TestTask.new("test_units") do |t|
  t.test_files = Dir.glob('test/**/*.rb')
  t.verbose = true
  t.warning = true
end

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

desc "Push changes"
task :push do
  system "/usr/local/bin/hg push"
  system "/usr/local/bin/hg push ssh://hg@bitbucket.org/keltia/old-crypto"
end

