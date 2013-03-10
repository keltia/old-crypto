# = skey.rb
#
# Description:: Substitution key
# Author:: Ollivier Robert <roberto@keltia.net>
# Copyright:: © 2001-2013 by Ollivier Robert
#
# $Id: skey.rb,v 7b4b32e1312e 2013/03/10 17:29:52 roberto $

require 'key/base'

module Key
  # == SKey
  #
  # class for simple substitution keys
  #
  # See http://en.wikipedia.org/wiki/Substitution_cipher

  class SKey < Key

    BASE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

    attr_reader :alpha, :ralpha

    def initialize(key)
      super(key)
      @alpha = Hash.new
      @ralpha = Hash.new
    end

    # === encode
    #
    def encode(c)
      @alpha[c] || c
    end # -- encode

    # === decode
    #
    def decode(c)
      @ralpha[c] || c
    end # -- decode

  end # -- SKey
end # -- Key
