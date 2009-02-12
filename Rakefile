# $Id: Rakefile,v 2371e41abf17 2009/02/12 23:25:02 roberto $
#
TESTDIR  = File.join(File.dirname(__FILE__), "test")

task :default => "test"

desc "Run test suite"
task :test do
  Dir.chdir(TESTDIR) do
    ruby "-I.. test_key.rb"
    ruby "-I.. test_cipher.rb"
  end
end
