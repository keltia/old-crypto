#! /usr/local/bin/ruby
#
# Copyright © 2001 by Ollivier Robert <roberto@keltia.freenix.fr>
#
# Implementation of the well known cipher used by Russian agents during
# WWII. Code number assignment is probably different from the original
# cipher due to implementation choices.
#
# See The Codebreakers, D. Kahn, 1996 for reference.
#
# Let our alphabet be ABCDEFGHIJKLMNOPQRSTUVWXYZ/-
#
# With key = SUBWAY, we form the following alphabet
#
# SUBWAYCDEFGHIJKLMNOPQRTVXZ/-
#
# in order to avoid sequential allocation of code #, we use the checkboard
# approach:
#
# Condensed key is SUBWAY
# Checkboard is
#
# SUBWAY
# CDEFGH
# IJKLMN
# OPQRTV
# XZ/-
#
# The final string will be
#
# SCIOXUDJPZBEKQ/WFLR-AGMTYHNV
#
# ESANTIRU will give the [0..7] pool in the order of appearance
# The rest of the letters are assigne 80..99.
#
# That would give us
# S = 0   C = 80  I = 1   O = 81  X = 82  U = 2   
# D = 83  J = 84  P = 85  Z = 86  B = 87  E = 3
# K = 88  Q = 89  / = 90  W = 91  F = 92  L = 93
# R = 4   - = 94  A = 5   G = 95  M = 96  T = 6   
# Y = 97  H = 98  N = 7   V = 99
#
# $Id: nihilist.rb,v 89d3551bbf2f 2009/01/22 15:40:09 roberto $

## Base alphabet
##

$base = "ABCDEFGHIJKLMNOPQRSTUVWXYZ/-"

class String
  ## -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  ## Condense word by removing every duplicated letter
  ##
  def condense_word
    c_alpha = ''
    
    self.scan(/./) {|c|
      if c_alpha !~ /#{c}/
        c_alpha = c_alpha + c
      end
    }
    c_alpha
  end
end

class Key < String
  attr_reader :key

  def initialize(key)
    raise ArgumentError if key.class != String and key and key.to_s == ""
    @key = key.to_s.upcase
  end

  def to_s
    @key.to_s
  end
  ## -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  ## Generate a numeric key from a keyword
  ##
  ## For each letter in the keyword, scan for the lowest letter, assign
  ## it an index # then scan again till there are no letter left
  ##
  def gen_numeric_key
    ## By Dave Thomas, IRC #ruby-lang on Thu Aug  9 17:36:39 CEST 2001
    ## 
    letters = @key.to_s.split('')
    sorted = letters.sort
    num_key = letters.collect {|l|
      k = sorted.index(l)
      sorted[k] = nil
      k + 1
    }
    num_key
  end

  def gen_numeric_key2
    ## By dblack, IRC #ruby-lang
    ##
    srt = @key.to_s.split('').sort

    n_key = @key.to_s.split('').map {|s|
      srt[srt.index(s)] = srt.index(s) + 1
    }
    n_key
  end
end

class CKey < Key
  def initialize(key)
    super(key)
  end

  def to_s
    @key.condense_word
  end
end

class Cipher
  attr_reader :alpha, :ralpha, :key
  
  def initialize(key)
    @key = Key.new(key)
    @alpha = Hash.new
    @ralpha = Hash.new
  end

  def forward
    @alpha.keys.sort.each {|k|
      v = @alpha[k].to_i
      yield k, v
    }
  end

  def reverse
    @ralpha.keys.sort.each {|k|
      v = @ralpha[k].to_s
      yield k, v
    }
  end

end

class Nihilist < Cipher
  attr_reader :super_key

  def initialize(key, super_key = "")
    super(key)
    complete = ''
    complete = (@key.to_s.upcase + $base).condense_word
    code_word(gen_checkbd(complete, @key.to_s.length))
    @super_key = super_key
  end

  private

  ## -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  ## Shuffle the alphabet a bit to avoid sequential allocation of the
  ## code numbers
  ##
  ## Regular rectangle
  ## -----------------
  ## Key is ARABESQUE condensed into ARBESQU (len = 7) (height = 4)
  ## Let word be ARBESQUCDFGHIJKLMNOPTVWXYZ/-
  ##
  ## First passes will generate
  ##
  ## A  RBESQUCDFGHIJKLMNOPTVWXYZ/-   c=0  0 x 6
  ## AC  RBESQUDFGHIJKLMNOPTVWXYZ/-   c=6  1 x 6
  ## ACK  RBESQUDFGHIJLMNOPTVWXYZ/-   c=12 2 x 6
  ## ACKV  RBESQUDFGHIJLMNOPTWXYZ/-   c=18 3 x 6
  ## ACKVR  BESQUDFGHIJLMNOPTWXYZ/-   c=0  0 x 5
  ## ACKVRD  BESQUFGHIJLMNOPTWXYZ/-   c=5  1 x 5
  ## ...
  ## ACKVRDLWBFMXEGNYSHOZQIP/UJT-
  ##
  ## Irregular rectangle
  ## -------------------
  ## Key is SUBWAY condensed info SUBWAY (len = 6) (height = 5)
  ##
  ## S  UBWAYCDEFGHIJKLMNOPQRTVXZ/-   c=0  0 x 5
  ## SC  UBWAYDEFGHIJKLMNOPQRTVXZ/-   c=5  1 x 5
  ## SCI  UBWAYDEFGHJKLMNOPQRTVXZ/-   c=10 2 x 5
  ## SCIO  UBWAYDEFGHJKLMNPQRTVXZ/-   c=15 3 x 5
  ## SCIOX  UBWAYDEFGHJKLMNPQRTVZ/-   c=20 4 x 5
  ## SCIOXU  BWAYDEFGHJKLMNPQRTVZ/-   c=0  0 x 4
  ## ...
  ## SCIOXUDJPZBEKQ/WFLR-AG  YHMNTV   c=1  1 x 1
  ## SCIOXUDJPZBEKQ/WFLR-AGM  YHNTV   c=2  2 x 1
  ## SCIOXUDJPZBEKQ/WFLR-AGMT  YHNV   c=3  3 x 1
  ## SCIOXUDJPZBEKQ/WFLR-AGMTYHNV

  def gen_checkbd(word, len)
    height = $base.length / len
    
    # Odd rectangle
    if ($base.length % len) != 0
      height = height + 1
    end
    
    print "\ncheckboard size is #{len} x #{height}\n"
    res = ""
    (len - 1).downto(0) {|i|
      0.upto(height - 1) {|j|
        if word.length <= (height - 1)
          return res + word
        else
          c = word.slice!(i * j).chr
          res = res + c
        end
      }
    }
    return res
  end 

  ## -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  ## Assign a code number for each letter. Each code number is
  ## sequentially allocated from two pools, one with 0..7 and
  ## the other with 80..99.
  ##
  ## Allocation is made on the following criterias
  ## - if letter is one of ESANTIRU assign a single code number
  ## - else assign of of the two letters ones
  ##
  ## Generate both the encoding and decoding rings.
  ##
  def code_word(key)
    ind_u = 0
    ind_d = 80

    key.to_s.scan(/./) {|c|
      if c =~ /[ESANTIRU]/
        @alpha[c] = ind_u
        @ralpha[ind_u] = c
        ind_u = ind_u + 1
      else
        @alpha[c] = ind_d
        @ralpha[ind_d] = c
        ind_d = ind_d + 1
      end
    }
  end

end

if $0 == __FILE__
  a = CKey.new(ARGV[0].to_s.chomp)
  puts a.to_s

  b = Key.new(ARGV[1].to_s.chomp)
  print "generic " + b.gen_numeric_key.join(',')
  puts ""
  print "key2 " + b.gen_numeric_key2.join(',')

  c = Nihilist.new(a)
  puts c.key.to_s

  c.forward {|key, val|
    print "#{key} -> #{val}\n"
  }
  puts ""
#  c.reverse {|key, val|
#    print "#{key} -> #{val}\n"
#  }

  exit 0
end
