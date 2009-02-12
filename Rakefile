# $Id: Rakefile,v 79032e572710 2009/02/12 21:15:13 roberto $
#
TESTDIR  = File.join(File.dirname(__FILE__), "test")

desc "Run test suite"
task :test do
  Dir.chdir(TESTDIR) do
    ruby "-I.. test_key.rb"
  end
end
