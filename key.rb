#! /usr/bin/env ruby
#
# Description:: Dealing with encryption keys
# Author:: Ollivier Robert <roberto@keltia.freenix.fr>
# Copyright:: © 2001-2009 by Ollivier Robert 
#

# VCS stuff
#
VCS_ID = "$Id: key.rb,v 0dde729d0219 2009/02/03 23:30:01 roberto $"

# == class String
#
class String
  
  # === condensed
  #
  # Condense word by removing every duplicated letter
  #
  def condensed
    c_alpha = ''
    
    self.scan(/./) do |c|
      if c_alpha !~ /#{c}/
        c_alpha = c_alpha + c
      end
    end
    c_alpha
  end # -- condensed

end # -- class String


# == class Key
#
# Virtual base class for keys
#
class Key
  attr_reader :key

  def initialize(key)
    raise ArgumentError if key.class != String and key and key.to_s == ""
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
  
end # -- class Key

# == class TKey
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

end # -- class TKey

# == class SKey
#
# class for simple substitution keys
#
# See http://en.wikipedia.org/wiki/Substitution_cipher

class SKey < Key
  attr_reader :alpha, :ralpha

  def initialize(key)
    super(key)
  end
  
end # -- class SKey

# == class SCKey
#
# class for straddling checkerboard substitution keys
#
# SC-keys needs to be condensed and rings generated for ciphering/deciphering
#
# See http://en.wikipedia.org/wiki/Straddling_checkerboard

class SCKey < Key

  BASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ/-"

  attr_reader :full_key
  attr_reader :alpha, :ralpha
  
  def initialize(key)
    super(key)
    @alpha = Hash.new
    @ralpha = Hash.new
    @full_key = checkerboard()
    gen_rings()
  end
  
  # === checkerboard
  #
  # Shuffle the alphabet a bit to avoid sequential allocation of the
  # code numbers
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
    
    print "\ncheckerboard size is #{len} x #{height}\n"
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
  # XXX FIXME Use of 80-99 is hardcoded
  #
  def gen_rings
    ind_u = 0
    ind_d = 80

    word = @full_key.dup
    word.scan(/./) do |c|
      if c =~ /[ESANTIRU]/
        @alpha[c] = ind_u
        @ralpha[ind_u] = c
        ind_u = ind_u + 1
      else
        @alpha[c] = ind_d
        @ralpha[ind_d] = c
        ind_d = ind_d + 1
      end
    end
  end # -- gen_rings

end # -- class SCKey

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
