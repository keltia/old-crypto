#! /usr/bin/env ruby
#
# = key.rb various key handling classes
#
# Description:: Dealing with encryption keys
# Author:: Ollivier Robert <roberto@keltia.freenix.fr>
# Copyright:: © 2001-2009 by Ollivier Robert 
#
# $Id: key.rb,v 5599ee896d07 2010/07/30 12:40:48 roberto $

require "crypto_helper"

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

  BASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ/-"

  attr_reader :full_key, :long, :shortc, :longc
  
  def initialize(key, longc = [ 8, 9 ])
    super(key)
    @longc = longc
    @full_key = checkerboard()
    gen_rings()
  end
  
  # === checkerboard
  #
  # Shuffle the alphabet a bit to avoid sequential allocation of the
  # code numbers.  This is actually performing a transposition with the word
  # itself as key.
  #
  # Regular rectangle
  # -----------------
  # Key is ARABESQUE condensed into ARBESQU (len = 7) (height = 4)
  # Let word be ARBESQUCDFGHIJKLMNOPTVWXYZ/-
  #
  # First passes will generate
  #
  # A  RBESQUCDFGHIJKLMNOPTVWXYZ/-   c=0  0 x 6
  # AC  RBESQUDFGHIJKLMNOPTVWXYZ/-   c=6  1 x 6
  # ACK  RBESQUDFGHIJLMNOPTVWXYZ/-   c=12 2 x 6
  # ACKV  RBESQUDFGHIJLMNOPTWXYZ/-   c=18 3 x 6
  # ACKVR  BESQUDFGHIJLMNOPTWXYZ/-   c=0  0 x 5
  # ACKVRD  BESQUFGHIJLMNOPTWXYZ/-   c=5  1 x 5
  # ...
  # ACKVRDLWBFMXEGNYSHOZQIP/UJT-
  #
  # Irregular rectangle
  # -------------------
  # Key is SUBWAY condensed info SUBWAY (len = 6) (height = 5)
  #
  # S  UBWAYCDEFGHIJKLMNOPQRTVXZ/-   c=0  0 x 5
  # SC  UBWAYDEFGHIJKLMNOPQRTVXZ/-   c=5  1 x 5
  # SCI  UBWAYDEFGHJKLMNOPQRTVXZ/-   c=10 2 x 5
  # SCIO  UBWAYDEFGHJKLMNPQRTVXZ/-   c=15 3 x 5
  # SCIOX  UBWAYDEFGHJKLMNPQRTVZ/-   c=20 4 x 5
  # SCIOXU  BWAYDEFGHJKLMNPQRTVZ/-   c=0  0 x 4
  # ...
  # SCIOXUDJPZBEKQ/WFLR-AG  YHMNTV   c=1  1 x 1
  # SCIOXUDJPZBEKQ/WFLR-AGM  YHNTV   c=2  2 x 1
  # SCIOXUDJPZBEKQ/WFLR-AGMT  YHNV   c=3  3 x 1
  # SCIOXUDJPZBEKQ/WFLR-AGMTYHNV
  #
  def checkerboard
    word = (@key + BASE).condensed.dup
    len = @key.condensed.length
    height = BASE.length / len
    
    
    # Odd rectangle
    #
    if (BASE.length % len) != 0
      height = height + 1
    end
    
    res = ""
    (len - 1).downto(0) do |i|
      0.upto(height - 1) do |j|
        if word.length <= (height - 1) then
          return res + word
        else
          c = word.slice!(i * j)
          if not c.nil? then
            res = res + c.chr
          end
        end
      end
    end
    return res
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
      if c =~ /[ESANTIRU]/
        ind = shortc.shift
        @alpha[c] = ind.to_s
        @ralpha[ind.to_s] = c
      else
        ind = long.shift
        @alpha[c] = ind.to_s
        @ralpha[ind.to_s] = c
      end
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
  
  # === encode
  #
  # Same row: p(r,c) -> p(r, c + 1 mod 5) 
  # Same col: p(r,c) -> p(r + 1 mod 5, c)
  # Diff.col/row:
  #  P = K(r1,c1),K(r2,c2) -> C = K(r1,c2),K(r2,c1)
  #
  def encode(c)
    p1, p2 = c.split(//)
    r1, c1 = @alpha[p1]
    r2, c2 = @alpha[p2]
    if r1 == r2 then
       return @ralpha[[r1, (c1 + 1) % 5]] + @ralpha[[r2, (c2 + 1) % 5]]
    end
    if c1 == c2 then
       return @ralpha[[(r1 + 1) % 5, c1]] + @ralpha[[(r2 + 1) % 5, c2]]
    end
    return @ralpha[[r1, c2]] + @ralpha[[r2, c1]]
  end # -- encode
  
  # === decode
  #
  # Decoding is the same if the two letters form a square.  If same row or
  # same col, take the previous letter (mod 5) in the array
  #
  def decode(c)
    p1, p2 = c.split(//)
    r1, c1 = @alpha[p1]
    r2, c2 = @alpha[p2]
    if r1 == r2 then
       return @ralpha[[r1, (c1 + 4) % 5]] + @ralpha[[r2, (c2 + 4) % 5]]
    end
    if c1 == c2 then
       return @ralpha[[(r1 + 4) % 5, c1]] + @ralpha[[(r2 + 4) % 5, c2]]
    end
    return @ralpha[[r1, c2]] + @ralpha[[r2, c1]]
  end # -- decode
  
end # -- Playfair

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
