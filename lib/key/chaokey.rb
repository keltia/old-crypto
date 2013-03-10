# = chaokey.rb
#
# Description:: Chaocipher substitution key
# Author:: Ollivier Robert <roberto@keltia.net>
# Copyright:: © 2001-2013 by Ollivier Robert
#
# $Id: chaokey.rb,v 4a72faeea033 2013/03/10 18:23:32 roberto $

require 'key/base'

module Key
  # == ChaoKey
  #
  # Setup key schedule & encode:decode methods for the Chaocipher
  # algorithm.
  # See http://www.mountainvistasoft.com/chaocipher/index.htm
  #
  class ChaoKey < Key
    BASE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    ZENITH = 0
    NADIR  = 13

    attr_reader :plain, :cipher

    def initialize(pw, cw)
      @plain  = pw
      @cipher = cw
      [pw, cw].each do |e|
        raise DataError, "Bad #{e} length" if e.length != BASE.length
      end
    end

    # === encode
    #
    def encode(c)
      return encode_or_decode(plain, cipher, c)
    end # -- encode

    # === decode
    #
    def decode(c)
      return encode_or_decode(cipher, plain, c)
    end # -- decode

    # === encode_or_decode
    #
    def encode_or_decode(r1, r2, c)
      idx = r1.index(c)
      pt = r2[idx]
      advance(idx)
      return pt.chr
    end # -- encode_or_decode

    # === advance
    #
    # Permute the two alphabets, first ciphertext then plaintext
    # We use the current plain & ciphertext characters (akin to autoclave)
    #
    # Zenith is 0, Nadir is 13 (n/2 + 1 if 1-based)
    # Steps for left:
    # 1. shift from idx to Zenith
    # 2. take Zenith+1 out
    # 3. shift left one position and insert back the letter from step2
    #
    # Steps for right
    # 1. shift everything from plain to Zenith
    # 2. shift one more entire string
    # 3. extract Zenith+2
    # 4. shift from Zenith+3 to Nadir left
    # 5. insert  letter from step 3 in place
    #
    def advance(idx)
      if idx != 0 then
        cw = @cipher[idx..-1] + @cipher[ZENITH..(idx - 1)]
        pw = @plain[idx..-1] + @plain[ZENITH..(idx - 1)]
      else
        cw = @cipher
        pw = @plain
      end
      @cipher = cw[ZENITH].chr + cw[(ZENITH + 2)..NADIR] + \
              cw[ZENITH + 1].chr + cw[(NADIR + 1)..-1]
      raise DataError, 'cw length bad' if cw.length != BASE.length

      pw = pw[(ZENITH + 1)..-1] + pw[ZENITH].chr
      @plain = pw[ZENITH..(ZENITH + 1)] + pw[(ZENITH + 3)..NADIR] + \
             pw[ZENITH + 2].chr + pw[(NADIR + 1)..-1]
      raise DataError, 'pw length bad' if pw.length != BASE.length
    end # -- advance

  end # -- ChaoKey
end # -- Key
