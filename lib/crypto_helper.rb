# crypto_helper.rb
#
# Description::  Helpers modules
# Author:: Ollivier Robert <roberto@keltia.freenix.fr>
# Copyright:: © 2001-2009 by Ollivier Robert 
#
# $Id: crypto_helper.rb,v 1d557f2f8b62 2013/03/05 14:28:17 roberto $


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
    self.each_char.inject('') {|s,c|
      if s.include?(c)
        c = ''
      end
      s+c
    }
  end # -- condensed

  # === expand
  #
  # Insert an X between identical letters (mostly used for bigrammatic
  # ciphers such as Playfair)
  #
  def expand(letter = 'X')
    a_str = self.split(//)
    i = 0
    while i < a_str.length do
      if a_str[i] == a_str[i+1]
        a_str.insert(i+1, letter)
      end
      i += 2
    end
    a_str.join.to_s
  end # -- expand

  # === replace_double
  #
  # Replace the second of two identical letters by Q (used for Wheatstone
  # cipher)
  #
  def replace_double(letter = 'Q')
    self.each_char.inject('') {|s,c|
      if s[-1] == c
        c = letter
      end
      s+c
    }
  end # -- replace_double

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
    letters = self.to_s.split('')
    sorted = letters.sort
    letters.collect do |l|
      k = sorted.index(l)
      sorted[k] = nil
      k
    end
  end # -- to_numeric

  # === to_numeric2
  #
  # Alternate version
  # By dblack, IRC #ruby-lang
  #
  # This version is more than 3 times as slow as #to_numeric
  # See misc/bench.rb
  #
  # XXX modified to be 0-based
  #
  def to_numeric2
    srt = self.split('').sort

    self.split('').map do |s|
      srt[srt.index(s)] = srt.index(s)
    end
  end # -- to_numeric2

  # === to_numeric10
  #
  # 1-based version modulo 10
  #
  # Based on:
  # For each letter in the keyword, scan for the lowest letter, assign
  # it an index # then scan again till there are no letter left
  #
  # By Dave Thomas, IRC #ruby-lang on Thu Aug  9 17:36:39 CEST 2001
  #
  def to_numeric10
    letters = self.to_s.split('')
    sorted = letters.sort
    letters.collect do |l|
      k = sorted.index(l)
      sorted[k] = nil
      (k + 1) % 10
    end
  end # -- to_numeric10
  
  # === to_numeric11
  #
  # 1-based version modulo 10
  #
  # Based on:
  # Alternate version
  # By dblack, IRC #ruby-lang
  #
  def to_numeric11
    srt = self.split('').sort

    self.split('').map do |s|
      srt[srt.index(s)] = (srt.index(s) + 1) % 10
    end
  end # -- to_numeric11
  
  # === by_five
  #
  # Slice input into 5-letter groups
  #
  def by_five
    str = self.dup
    l = str.length
    r = l % 5
    if l <= 5
      return str
    else
      a = str.scan(%r{(\w{5})}).join(' ')
    end
    if r != 0
      a += ' '+ str[-r, r]
    end
    a
  end # -- by_five

  # === un_five
  #
  # Reverse #by_five
  #
  def un_five
    str = self.dup
    str.gsub(%r{ }, '')
  end # -- un_five

  # === frequency
  #
  # Returns the frequency of each letters (or only the ones given)
  #
  def frequency(a = nil)
    if a.nil?
      a = self.dup.condensed
    end

    a.scan(/./).collect do |i|
        [i, self.count(i)]
    end
  end # -- frequency
end # -- String

module Crypto
  
  # === normalize
  #
  def normalize(a)
    a.collect!{|e| (e + 1) % 10 }
  end # -- normalize
  
  # === str_to_numeric
  #
  # Returns an array of each digit
  #
  def str_to_numeric(str)
    str.split('').collect{|i|  i.to_i }
  end # -- to_numeric
  
  # === p1_encode
  #
  # This encoding method uses the array p2 to encode array p1
  # in a simplified tabular substitution
  #
  def p1_encode(p1, p2)
    r = Array.new
    p1.each do |e|
      r << p2[(e + 10) % 10 - 1]
    end
    r
  end # -- p1_encode
  
  # === chainadd
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
  def chainadd(a)
    b = a.dup
    len = a.length
    a.each_with_index{|e,i| b[i] = (e + b[(i+1) % len]) % 10 }
    b
  end # -- chainadd
  
  # == expand5to10
  #
  # Use chainadd to generate the expanded key
  #
  def expand5to10(a)
    expd = chainadd(a)
    (a + expd)
  end # -- expand5to10
  
  # === addmod10
  #
  # Addition modulo 10
  #
  def addmod10(a, b)
    raise DataError if a.length != b.length
    (0..a.length-1).collect {|i| (a[i] + b[i]) % 10  }
  end # -- addmod10
  
  # === submod10
  #
  # Substraction modulo 10 (step 1)
  #
  def submod10(a, b)
    len = a.length
    (0..len-1).collect{|i| (a[i] - b[i] + 10) % 10 }
  end # -- submod10
  
  # === keyshuffle
  #
  # Form an alphabet formed with a keyword, re-shuffle everything to
  # make it less predictable (i.e. checkerboard effect)
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

  BASE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

  def keyshuffle(key, base = BASE)
    word = (key + base).condensed.dup
    len = key.condensed.length
    height = base.length / len
    
    
    # Odd rectangle
    #
    if (base.length % len) != 0
      height = height + 1
    end
    
    res = ''
    (len - 1).downto(0) do |i|
      0.upto(height - 1) do |j|
        if word.length <= (height - 1)
          return res + word
        else
          c = word.slice!(i * j)
          unless c.nil?
            res = res + c.chr
          end
        end
      end
    end
    res
  end # -- keyshuffle

  # === find_hole
  #
  # Given a keyword with spaces, output an array with their positions
  #
  def find_hole(kw, ph = 'AT ONE SIR')
    if kw.class == String
      kwn = kw[0..(ph.length - 1)].to_numeric10
    elsif kw.class == Array
      kwn = kw.dup
    else
      raise DataError, 'Must be either String or Array of integers'
    end
    
    long  = Array.new
    short = Array.new
    i = 0
    ph.scan(/./).each do |c|
      if c == ' '
        long << kwn[i]
      else
        short << kwn[i]
      end
      i += 1
    end
    long.compact
  end # -- find_hole

  # === HoleArea
  #
  # Used to find 'holes' in a given according to a given keyword
  #
  # cf.
  # http://users.telenet.be/d.rijmenants/en/handciphers.htm
  #
  # Used mainly by Cipher::DisruptedTransposition
  #
  class HoleArea
    include Enumerable

    attr_reader :a, :len, :xlen, :ylen, :totalx

    def initialize(start_row, pos, xlen, len)
      @a = Array.new
      @xlen = xlen.to_i
      @totalx = pos.to_i + xlen.to_i
      @totaly = (len.to_i / @totalx) + 1
      cpos = pos
      for j in start_row..(@totaly - 1) do
        for i in cpos..(pos + xlen - 1) do
          @a << [ j, i ] if (( (j * totalx) + i) < len)
        end
        # We shift by one to the right
        cpos += 1
      end
      @ylen = @a[-1][0] - start_row + 1
      @cf = (@a.size == (xlen * (xlen + 1)) / 2)
    end

    # === each
    #
    # Needed for every Enumerable
    #
    def each
      @a.each do |c|
        yield c
      end
    end # -- each

    # === complete?
    #
    # Flag testing whether the area is complete or not
    # (i.e. is a full triangle)
    #
    def complete?
      @cf
    end
  end # -- HoleArea

end # -- Crypto

if __FILE__ == $0
  puts 'End.'
  find_hole('INDEPENDENCE','AT ONE SIR')
end