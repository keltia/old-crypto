# caesar.rb
#
# Description:: Basic caesar-like cipher
# Author:: Ollivier Robert <roberto@keltia.net>
# Copyright:: 2001-2013 © by Ollivier Robert
#
# $Id: caesar.rb,v 9ea677b34eed 2013/03/10 18:49:14 roberto $

require 'key/caesar'
require 'cipher/subst'

module Cipher
  # ==  Caesar
  #
  # Caesar cipher, monoalphabetic substitution, offset is 3
  #
  class Caesar < Substitution

    # === initialize
    #
    def initialize(offset = 3)
      @key = Key::Caesar.new(offset)
    end # -- initialize

  end # --  Caesar
end # -- Cipher
