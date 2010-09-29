# $Id: Rakefile,v 4a8461664a2a 2010/09/29 23:11:44 roberto $
#
require 'rake'
require 'rake/testtask'
#require 'hoe'

task :default => [:test_units]

desc "Run basic tests"
Rake::TestTask.new("test_units") { |t|
  t.pattern = 'test/test_*.rb'
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

#Hoe.spec 'OldCrypto' do
#  self.developer('Ollivier Robert', 'roberto@keltia.net')
#  self.version = OldCrypto::VERSION
#end

