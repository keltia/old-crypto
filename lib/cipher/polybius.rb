# polybius.rb
#
# Description:: Base Polybius class of ciphers
# Author:: Ollivier Robert <roberto@keltia.net>
# Copyright:: 2001-2013 © by Ollivier Robert
#
# $Id: polybius.rb,v e554d04c10ed 2013/03/10 19:05:48 roberto $

require 'key/sqkey'
require 'cipher/bigrammatic'

module Cipher
  # ==  Polybius
  #
  class Polybius < BiGrammatic

    # === initialize
    #
    def initialize(key, type = Key::SQKey::SQ_ADFGVX)
      super(Key::SQKey, key, type)
    end # -- initialize

  end # --  Polybius
end # -- Cipher
