#! /usr/bin/env ruby
#
# = key.rb various key handling classes
#
# Description:: Dealing with encryption keys
# Author:: Ollivier Robert <roberto@keltia.freenix.fr>
# Copyright:: © 2001-2009 by Ollivier Robert 
#
# $Id: key.rb,v b41c05c94e6a 2010/11/21 20:24:08 roberto $

require "crypto_helper"

class DataError < Exception
end

module Key
# == Key
#
# Virtual base class for keys
#
class Key
  attr_reader :key

  def initialize(key)
    raise ArgumentError if key.class != String and key.class != Fixnum
    if key.class == Fixnum then
      if key < 0 or key > 26 then
        raise RangeError
      end
    end
    @key = key.to_s.upcase
  end

  def to_s
    @key
  end
  
  # === condensed
  #
  def condensed
    @key.condensed
  end # -- condensed

  # === length
  #
  def length
    @key.length
  end # -- length
  
end # -- Key

# == TKey
#
# Class for transposition keys
#
# A transposition key does not ghet condensed but serve as a generator for
# a numeric key based on letters.  Later on, these numbers will be used to
# extract columns.
#
# See http://en.wikipedia.org/wiki/Transposition_cipher

class TKey < Key
  include Crypto
  
  def initialize(key)
    super(key)
  end
  
  # === to_numeric
  #
  def to_numeric
    @key.to_numeric
  end # -- to_numeric
  
end # -- TKey

# == SKey
#
# class for simple substitution keys
#
# See http://en.wikipedia.org/wiki/Substitution_cipher

class SKey < Key
  
  BASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  
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

# == Caesar
#
# class for Caesar-like substitution ciphers: monoalphabetic with ordered
# alphabet
#
# XXX Assume US-ASCII or lowest 256 chars of Unicode
#
class Caesar < SKey
  def initialize(key)
    super(key)
    gen_rings()
  end
  
  # === gen_rings
  #
  def gen_rings
    offset = @key.to_i
  
    if RUBY_VERSION =~ /1\.9/ then
      BASE.scan(/./) do |c|
        d = ( (((c.ord - 65) + offset) % 26) + 65).chr
        @alpha[c]  = d
        @ralpha[d] = c
      end
    else
      BASE.scan(/./) do |c|
        d = ( (((c[0] - 65) + offset) % 26) + 65).chr
        @alpha[c]  = d
        @ralpha[d] = c
      end
    end
  end # -- gen_rings
  
end # -- Caesar

# == SCKey
#
# class for straddling checkerboard substitution keys
#
# SC-keys needs to be condensed and rings generated for ciphering/deciphering
#
# See http://en.wikipedia.org/wiki/Straddling_checkerboard

class SCKey < SKey
  include Crypto
  BASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ/-"

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
      if "ESANTIRU".include? c then
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

# == SQKey
#
# Class for handling keys generated by a Polybius square.
#
# XXX only 6x6 square is implemented in order to
# 1. have the full alphabet
# 2. have numbers as well
#
# It also simplify the code
#
class SQKey < SKey

  BASE36 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

  SQ_NUMBERS = 1
  SQ_ADFGVX  = 2

  CODE_WORD = {
    SQ_NUMBERS => [ 0, 1, 2, 3, 4, 5 ],
    SQ_ADFGVX  => [ 'A', 'D', 'F', 'G', 'V', 'X' ],
  }

  attr_reader :full_key, :type
  
  def initialize(key, type = SQ_ADFGVX)
    super(key.gsub(%r{\s*}, ''))
    @alpha = Hash.new
    @ralpha = Hash.new
    @type = type
    @base = BASE36
    @full_key = (@key + @base).condensed
    gen_rings
  end
  
  # == gen_rings
  #
  # Assign a code number/letter for each letter.
  #
  # Generate both the encoding and decoding rings.
  #
  def gen_rings
    ind = 0
    word = @full_key.dup
    CODE_WORD[@type].each do |i|
      CODE_WORD[@type].each do |j|
        c = word[ind]
        @alpha[c.chr] = "#{i}#{j}"
        @ralpha["#{i}#{j}"] = c.chr
        ind += 1
      end
    end
  end # -- gen_rings

end # -- SQKey

# == Playfair
#
# The Playfait cipher was invented by Charles Wheatstone but popularized by
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
      @base = "ABCDEFGHIJKLMNOPRSTUVWXYZ"
    else
      @base = "ABCDEFGHIKLMNOPQRSTUVWXYZ"
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

# == WheatstoneKey
#
# The Wheatstone cipher (not to be confused with Playfair, also from the author) is a
# polyalphabetic stream cipher represented by a mechanical device with two synchronized
# rotors just like a clock called the Wheatstone Cryptograph.
#
# For more details see
# http://csc.colstate.edu/summers/Research/Cipher-Machines.doc
# http://bit.ly/983rDL
#
class WheatstoneKey < SKey
  include Crypto
  
  attr_accessor :plw, :ctw
  
  BASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  # == initialize
  #
  def initialize(start, plw = BASE, ctw = BASE)
    if plw.length != BASE.length then
      #
      # Assume al is a word we use as a base to generate an alphabet with #keyshuffle
      #
      @plw = keyshuffle(plw)
    end
    if ctw.length != BASE.length then
      #
      # Assume al is a word we use as a base to generate an alphabet with #keyshuffle
      #
      @ctw = keyshuffle(ctw)
    end
    
  end # -- initialize
  
end # -- WheatstoneKey

# == VICKey
#
# The VIC cipher is described on the following Wikipedia page:
# http://en.wikipedia.org/wiki/VIC_cipher
#
# and a working example is here:
# http://www.hypermaths.org/quadibloc/crypto/pp1324.htm
#
# XXX Most of the arrays' content is 1-based mod 10 data
# (i.e. 0 == 10 and 1 is the lowest)
#
# This uses a very complex key schedule as the basis of a straddling
# checkerboard.
#
# Step1 uses Crypto.expand5to10
# Step2 uses Crypto.chainadd on phrase (after conversion)
# Step3 uses the previously calculated data by running it 5 times through
# the Crypto.chainadd method.  The key thus calculated is then converted
# through a transposition.
#
class VICKey < Key
  include Crypto
  
  attr_reader :first, :second, :third, :p1, :p2, :ikey5, :sc_key
  
  # === initialize
  #
  def initialize(ikey, phrase, imsg)
    #
    # First phase
    #
    @ikey5 = str_to_numeric(ikey[0..4])
    @imsg = str_to_numeric(imsg)
    res = submod10(@imsg, @ikey5)
    @first = expand5to10(res)
    #
    # Second phase: we take the long numeric keys in two parts but we *must*
    # use normalize because String#to_numeric uses 0-based arrays) XXX
    #
    # We split the key phrase into two 10 digits parts @p1 & @p2
    # Then we add mod 10 @p1 and the first expanded ikey (as @first)
    #
    @p1 = normalize(phrase[0..9].to_numeric)
    @p2 = normalize(phrase[10..19].to_numeric)
    tmp = addmod10(@first, @p1)
    @second = p1_encode(tmp, @p2)
    #
    # Third phase
    #
    # We run 5 times through chainadd
    #
    r = @second.dup
    5.times do
      r = chainadd(r)
    end
    @third = r
    @sc_key = @third.join.to_numeric
  end # -- initialize
  
end # -- VICKey


# == ChaoKey
#
# Setup key schedule & encode:decode methods for the Chaocipher
# algorithm.
# See http://www.mountainvistasoft.com/chaocipher/index.htm
#
class ChaoKey < Key
  BASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
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
    raise DataError, "cw length bad" if cw.length != BASE.length

    pw = pw[(ZENITH + 1)..-1] + pw[ZENITH].chr
    @plain = pw[ZENITH..(ZENITH + 1)] + pw[(ZENITH + 3)..NADIR] + \
             pw[ZENITH + 2].chr + pw[(NADIR + 1)..-1]
    raise DataError, "pw length bad" if pw.length != BASE.length
  end # -- advance

end # -- ChaoKey

end # -- Key

if $0 == __FILE__ then
  
  # several test keys
  #
  # square
  #
  k = Key::SCKey.new("ARABESQUE")
  p k.condensed
  
  # not square but known -- see above comments
  #
  m = Key::SCKey.new("subway")
  p m.condensed
  
  # not square
  #
  n = Key::SCKey.new("portable")
  p n.condensed

  # key for transposition
  #
  t = Key::TKey.new("retribution")
  #
  #
  # Main usage, get the numerical order of letters
  #
  p t.to_numeric

  exit(0)
end
