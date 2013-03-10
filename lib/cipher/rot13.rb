# rot13.rb
#
# Description:: Speciall Caesar-based cipher
# Author:: Ollivier Robert <roberto@keltia.net>
# Copyright:: 2001-2013 © by Ollivier Robert
#
# $Id: rot13.rb,v e4300577d362 2013/03/10 18:50:29 roberto $

require 'key/caesar'
require 'cipher/subst'

module Cipher
  # == Rot13
  #
  # Special version for Internet, using offset of 13.
  #
  class Rot13 < Substitution

    # === initialize
    #
    def initialize(offset = 13)
      @key = Key::Caesar.new(offset)
    end # -- initialize

  end # --  Rot13
end # -- Cipher
