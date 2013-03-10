# = playfair.rb
#
# Description:: Playfair substitution key
# Author:: Ollivier Robert <roberto@keltia.net>
# Copyright:: © 2001-2013 by Ollivier Robert
#
# $Id: playfair.rb,v cba71d9f8dda 2013/03/10 18:05:47 roberto $

require 'key/skey'

module Key
  # == Playfair
  #
  # The Playfair cipher was invented by Charles Wheatstone but popularized by
  # his friend, the Baron Playfair.
  #
  # Description of the cipher on http://en.wikipedia.org/wiki/Playfair_cipher
  # JS version on http://www.simonsingh.net/The_Black_Chamber/playfaircipher.htm
  #
  # Playfair is a bigrammatic cipher but it does not use a Polybius square
  #
  class Playfair < SKey
    include Crypto

    CODE_WORD = [ 0, 1, 2, 3, 4 ]

    WITH_J = 0
    WITH_Q = 1

    attr_reader :full_key

    # === initialize
    #
    def initialize(key, type = WITH_Q)
      super(key.gsub(%r{\s*}, ''))
      @alpha = Hash.new
      if type == WITH_J then
        @base = 'ABCDEFGHIJKLMNOPRSTUVWXYZ'
      else
        @base = 'ABCDEFGHIKLMNOPQRSTUVWXYZ'
      end
      @full_key = (@key + @base).condensed
      gen_rings()
    end # -- initialize

    # === gen_rings
    #
    def gen_rings
      ind = 0
      word = @full_key.dup
      CODE_WORD.each do |i|
        CODE_WORD.each do |j|
          c = word[ind]
          @alpha[c.chr] = [ i, j ]
          @ralpha[[ i, j ]] = c.chr
          ind += 1
        end
      end
    end # -- gen_rings

    PLF_ENCODE = 1
    PLF_DECODE = 4

    # === encode
    #
    def encode(c)
      return encode_or_decode(c, PLF_ENCODE)
    end # -- encode

    # === decode
    #
    def decode(c)
      return encode_or_decode(c, PLF_DECODE)
    end # -- decode

    private
    # === encode_or_decode
    #
    # Same row: p(r,c) -> p(r, c + 1 mod 5)
    # Same col: p(r,c) -> p(r + 1 mod 5, c)
    # Diff.col/row:
    #  P = K(r1,c1),K(r2,c2) -> C = K(r1,c2),K(r2,c1)
    #
    # Decoding is the same if the two letters form a square.  If same row or
    # same col, take the previous letter (mod 5) in the array
    #
    def encode_or_decode(c, a)
      p1, p2 = c.split(//)
      r1, c1 = @alpha[p1]
      r2, c2 = @alpha[p2]
      if r1 == r2 then
        return @ralpha[[r1, (c1 + a) % 5]] + @ralpha[[r2, (c2 + a) % 5]]
      end
      if c1 == c2 then
        return @ralpha[[(r1 + a) % 5, c1]] + @ralpha[[(r2 + a) % 5, c2]]
      end
      return @ralpha[[r1, c2]] + @ralpha[[r2, c1]]
    end # -- encode_or_decode
  end # -- Playfair
end # -- Key
