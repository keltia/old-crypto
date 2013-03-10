# = caesar.rb
#
# Description:: Caesar-like key
# Author:: Ollivier Robert <roberto@keltia.net>
# Copyright:: © 2001-2013 by Ollivier Robert
#
# $Id: caesar.rb,v 632a7b33242b 2013/03/10 17:34:45 roberto $

require 'key/skey'

module Key
  # == Caesar
  #
  # class for Caesar-like substitution ciphers: monoalphabetic with ordered
  # alphabet
  #
  # XXX Assume US-ASCII or lowest 256 chars of Unicode
  #
  class Caesar < SKey
    attr_reader :offset

    def initialize(key)
      super(key)
      gen_rings()
    end

    # === gen_rings
    #
    def gen_rings
      @offset = @key.to_i

      BASE.scan(/./) do |c|
        d = ( (((c.ord - 65) + offset) % 26) + 65).chr
        @alpha[c]  = d
        @ralpha[d] = c
      end
    end # -- gen_rings

  end # -- Caesar
end # -- Key
