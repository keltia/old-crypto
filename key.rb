#! /usr/bin/env ruby
#
# = key.rb various key handling classes
#
# Description:: Dealing with encryption keys
# Author:: Ollivier Robert <roberto@keltia.freenix.fr>
# Copyright:: © 2001-2009 by Ollivier Robert 
#
# $Id: key.rb,v efa4a2342466 2009/03/05 18:36:24 roberto $

# == String
#
# Small addon to String class
#
class String
  
  # === condensed
  #
  # Condense word by removing every duplicated letter
  #
  def condensed
    c_alpha = ''
    
    self.scan(/./) do |c|
      if not c_alpha.include?(c) then
        c_alpha = c_alpha + c
      end
    end
    c_alpha
  end # -- condensed

end # -- String


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
  def initialize(key)
    super(key)
  end
  
  # === to_numeric
  #
  # Generate a numeric key from a keyword
  #
  # For each letter in the keyword, scan for the lowest letter, assign
  # it an index # then scan again till there are no letter left
  #
  # XXX modified to be 0-based
  #
  # By Dave Thomas, IRC #ruby-lang on Thu Aug  9 17:36:39 CEST 2001
  # 
  def to_numeric
    letters = @key.to_s.split('')
    sorted = letters.sort
    num_key = letters.collect do |l|
      k = sorted.index(l)
      sorted[k] = nil
      k
    end
    num_key
  end # -- to_numeric

  # === to_numeric2
  #
  # Alternate version
  # By dblack, IRC #ruby-lang
  #
  # XXX modified to be 0-based
  #
  def to_numeric2
    srt = @key.to_s.split('').sort

    n_key = @key.to_s.split('').map do |s|
      srt[srt.index(s)] = srt.index(s)
    end
    n_key
  end # -- to_numeric2

  # === to_numeric10
  #
  # 1-based version modulo 10
  #
  # Based on:
  # Alternate version
  # By dblack, IRC #ruby-lang
  #
  def to_numeric10
    srt = @key.to_s.split('').sort

    n_key = @key.to_s.split('').map do |s|
      srt[srt.index(s)] = (srt.index(s) + 1) % 10
    end
    n_key
  end # -- to_numeric10

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
    super
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
    long = @longc.collect{|i| (0..9).collect{|j| i*10+j } }.flatten
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
    super(key)
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
# Step1 uses VICKey.expand5to10
# Step2 uses VICKey.chainadd on phrase (after conversion)
#
class VICKey < Key
  attr_reader :first, :second, :third, :p1, :p2, :ikey5, :sc_key
  
  # === initialize
  #
  def initialize(ikey, phrase, imsg)
    #
    # First phase
    #
    @ikey5 = VICKey.to_numeric(ikey[0..4])
    @imsg = VICKey.to_numeric(imsg)
    res = VICKey.submod10(@imsg, @ikey5)
    @first = VICKey.expand5to10(res)
    #
    # Second phase (we use TKey to get numeric keys but we *must* use 
    # normalize because TKey uses 0-based arrays) XXX
    #
    # We split the key phrase into two 10 digits parts @p1 & @p2
    # Then we add mod 10 @p1 and the first expanded ikey (as @first)
    #
    @p1 = VICKey.normalize(TKey.new(phrase[0..9]).to_numeric)
    @p2 = VICKey.normalize(TKey.new(phrase[10..19]).to_numeric)
    tmp = VICKey.addmod10(@first, @p1)
    @second = VICKey.p1_encode(tmp, @p2)
    #
    # Third phase
    #
    # We run 5 times through chainadd
    #
    r = @second.dup
    5.times do
      r = VICKey.chainadd(r)
    end
    @third = r
    @sc_key = TKey.new(@third.join).to_numeric
  end # -- initialize
  
  # === normalize
  #
  def VICKey.normalize(a)
    a.collect!{|e| (e + 1) % 10 }
  end # -- normalize
  
  # === to_numeric
  #
  # XXX ASCII-dependant
  #
  def VICKey.to_numeric(str)
    str.split('').collect{|i| i.to_i }
  end # -- to_numeric
  
  # === p1_encode
  #
  # This encoding method uses the array p2 to encode array p1
  # in a simplified tabular substitution
  #
  def VICKey.p1_encode(p1, p2)
    r = Array.new
    p1.each do |e|
      r << p2[(e + 10) % 10 - 1]
    end
    r
  end # -- p1_encode
  
  # === VICKey.chainadd
  #
  # [ a0, a1, a2, a3, a4 ] is transformed into
  # [ b0, b1, b2, b3, b4 ]
  #
  # b0 = a0 + a1
  # b1 = a1 + a2
  # b2 = a2 + a3
  # b3 = a3 + a4
  # b4 = a4 + b0
  #
  #
  def VICKey.chainadd(a)
    b = a.dup
    len = a.length
    a.each_with_index{|e,i| b[i] = (e + b[(i+1) % len]) % 10 }
    b
  end # -- chainadd
  
  # == VICKey.expand5to10
  #
  # Use VICKey.chainadd to generate the expanded key
  #
  def VICKey.expand5to10(data)
    expd = VICKey.chainadd(data)
    (data + expd)
  end # -- expand5to10
  
  # === addmod10
  #
  # Addition modulo 10
  #
  def VICKey.addmod10(a, b)
    raise DataError if a.length != b.length
    (0..a.length-1).collect {|i| (a[i] + b[i]) % 10  }
  end # -- addmod10
  
  # === submod10
  #
  # Substraction modulo 10 (step 1)
  #
  def VICKey.submod10(a, b)
    len = a.length
    c = (0..len-1).collect{|i| (a[i] - b[i] + 10) % 10 }
  end # -- submod10
  
end # -- VICKey

if $0 == __FILE__ then
  
  # several test keys
  #
  # square
  #
  k = SCKey.new("ARABESQUE")
  p k.condensed
  
  # not square but known -- see above comments
  #
  m = SCKey.new("subway")
  p m.condensed
  
  # not square
  #
  n = SCKey.new("portable")
  p n.condensed

  # key for transposition
  #
  t = TKey.new("retribution")
  #
  #
  # Main usage, get the numerical order of letters
  #
  p t.to_numeric

  exit(0)
end
