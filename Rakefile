# $Id: Rakefile,v 26d3386bd301 2009/03/09 22:26:19 roberto $
#
require 'rake'
require 'rake/testtask'
require 'hoe'

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

require './lib/old_crypto.rb'

Hoe.new('OldCrypto', OldCrypto::VERSION) do |p|
  p.developer('Ollivier Robert', 'roberto@keltia.freenix.fr')
end

