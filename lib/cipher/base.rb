# base.rb
#
# Description:: Base simple class for Cipher::
# Author:: Ollivier Robert <roberto@keltia.net>
# Copyright:: 2001-2013 © by Ollivier Robert
#
# $Id: base.rb,v 98f23597bd3c 2013/03/10 18:37:21 roberto $

require 'key'

module Cipher
  # ==  SimpleCipher
  #
  # Base class, encode() returns plain text as does decode()
  #
  class SimpleCipher
    # === encode
    #
    def encode(text)
      return text
    end # -- encode

    # === decode
    #
    def decode(text)
      return text
    end # -- decode

  end # -- SimpleCipher
end # -- Cipher
