# -*- encoding: utf-8 -*-
#
# $Id$
#
$:.push File.expand_path("../lib", __FILE__)
require "old-crypto/version"

Gem::Specification.new do |s|
  s.name        = "old-crypto"
  s.version     = OldCrypto::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ollivier Robert"]
  s.email       = ["roberto@keltia.net"]
  s.homepage    = "http://dev.keltia.net/projects/old-crypto"
  s.summary     = %q{Ancient ciphers reimplemented in Ruby.}
  s.description = %q{Clean implementation of ancient ciphers in Ruby.}

  s.rubyforge_project = "old-crypto"

  s.files         = `/usr/local/bin/hg locate`.split("\n")
  s.test_files    = `/usr/local/bin/hg locate -- {test,spec,features}/*`.split("\n")
  s.executables   = `/usr/local/bin/hg locate -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
