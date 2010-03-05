# crypto_helper.rb
#
# Description::  Helpers modules
# Author:: Ollivier Robert <roberto@keltia.freenix.fr>
# Copyright:: © 2001-2009 by Ollivier Robert 
#
# $Id: crypto_helper.rb,v 762197de3fd1 2010/03/05 22:37:41 roberto $


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

  # === expand
  #
  def expand
    a_str = self.split(//)
    i = 0
    while i < a_str.length do
      if a_str[i] == a_str[i+1] then
        a_str.insert(i+1, "X")
      end
      i += 2
    end
    return a_str.join.to_s
  end # -- expand
  
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
  # This version is more than 3 times as slow as #to_numeric
  # See misc/bench.rb
  #
  # XXX modified to be 0-based
  #
  def to_numeric2
    srt = self.split('').sort

    n_key = self.split('').map do |s|
      srt[srt.index(s)] = srt.index(s)
    end
    n_key
  end # -- to_numeric2

  # === to_numeric11
  #
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
    num_key = letters.collect do |l|
      k = sorted.index(l)
      sorted[k] = nil
      (k + 1) % 10
    end
    num_key
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

    n_key = self.split('').map do |s|
      srt[srt.index(s)] = (srt.index(s) + 1) % 10
    end
    n_key
  end # -- to_numeric11
  
  # === by_five
  #
  # Slice input into 5-letter groups
  #
  def by_five
    str = self.dup
    l = str.length
    r = l % 5
    if l <= 5 then
      return str
    else
      a = str.scan(%r{(\w{5})}).join(' ')
    end
    if r != 0 then
      a += " "+ str[-r, r]
    end
    return a
  end # -- by_five
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
  
end # -- Crypto
