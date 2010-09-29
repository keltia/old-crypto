# $Id: Rakefile,v b4b5278e9199 2010/09/29 23:11:28 roberto $
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

require './lib/old_crypto.rb'

#Hoe.spec 'OldCrypto' do
#  self.developer('Ollivier Robert', 'roberto@keltia.net')
#  self.version = OldCrypto::VERSION
#end

