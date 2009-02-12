# $Id: Rakefile,v 7f69ba3ed4f1 2009/02/12 21:18:11 roberto $
#
TESTDIR  = File.join(File.dirname(__FILE__), "test")

task :default => "test"

desc "Run test suite"
task :test do
  Dir.chdir(TESTDIR) do
    ruby "-I.. test_key.rb"
  end
end
