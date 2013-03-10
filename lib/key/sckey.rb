# = sckey.rb
#
# Description:: Straddling Checkerboard key
# Author:: Ollivier Robert <roberto@keltia.net>
# Copyright:: © 2001-2013 by Ollivier Robert
#
# $Id: sckey.rb,v 215f60fa1e7f 2013/03/10 17:52:14 roberto $

require 'key/skey'

module Key
  # == SCKey
  #
  # class for straddling checkerboard substitution keys
  #
  # SC-keys needs to be condensed and rings generated for ciphering/deciphering
  #
  # See http://en.wikipedia.org/wiki/Straddling_checkerboard

  class SCKey < SKey
    include Crypto
    BASE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ/-'

    attr_reader :full_key, :shortc, :longc

    def initialize(key, longc = [ 8, 9 ])
      super(key)
      @longc = longc
      @full_key = keyshuffle(@key, BASE)
      gen_rings()
    end

    # == gen_rings
    #
    # Assign a code number for each letter. Each code number is
    # sequentially allocated from two pools, one with 0..7 and
    # the other with 80..99.
    #
    # Allocation is made on the following criterias
    # - if letter is one of ESANTIRU assign a single code number
    # - else assign of of the two letters ones
    #
    # Generate both the encoding and decoding rings.
    #
    def gen_rings
      shortc = (0..9).collect{|i| i unless @longc.include?(i) }.compact
      raise DataError if shortc.nil?
      long = @longc.collect{|i| (0..9).collect{|j| i*10+j } }.flatten
      raise DataError if long.nil?
      @shortc = shortc.dup

      word = @full_key.dup
      word.scan(/./) do |c|
        if 'ESANTIRU'.include? c then
          ind = shortc.shift
        else
          ind = long.shift
        end
        @alpha[c] = ind.to_s
        @ralpha[ind.to_s] = c
      end
    end # -- gen_rings

    # === is_long?
    #
    def is_long?(digit)
      return @longc.include?(digit)
    end # -- is_long?

  end # -- SCKey
end # -- Key
