#
# $Id: cipher.rb,v a93cbaec67c3 2009/02/24 11:25:23 roberto $

require "key"

module Cipher

# == class SimpleCipher
#
# Base class, encode() returns plain text as does decode()
#
class SimpleCipher
  # === encode
  #
  def encode(text)
    return text
  end # -- encode
  
  # === decode
  #
  def decode(text)
    return text
  end # -- decode
  
end # -- SimpleCipher

# class Substitution
#
# Class for substitution cipher (Caesar, Polyalphabetic, Nihilist)
#
class Substitution < SimpleCipher
  attr_reader :key
  
  def initialize(key)
    @key = SKey.new(key)
  end

  # === encode
  #
  def encode(plain_text)
    cipher_text = ""
    plain_text.scan(/./) do |pt|
      ct = @key.encode(pt)
      cipher_text << ct
    end
    return cipher_text
  end # -- encode
  
  # === decode
  #
  def decode(cipher_text)
    plain_text = ""
    cipher_text.scan(/./) do |pt|
      ct = @key.decode(pt)
      plain_text << ct
    end
    return plain_text
  end # -- decode
  
  # === forward
  #
  def forward
    @key.alpha.keys.sort.each do |k|
      v = @key.alpha[k].to_i
      yield k, v
    end
  end # -- forward

  # === reverse
  #
  def reverse
    @key.ralpha.keys.sort.each do |k|
      v = @key.ralpha[k].to_s
      yield k, v
    end
  end # -- reverse
end # -- class Cipher

# == class Caesar
#
# Caesar cipher, monoalphabetic substitution, offset is 3
#
class Caesar < Substitution
  
  # === initialize
  #
  def initialize(offset = 3)
    @key = ::Caesar.new(offset)
  end # -- initialize
  
end # -- class Caesar

# == class Polybius
#
class Polybius < Substitution
  
  # === initialize
  #
  def initialize(key, type = SQKey::SQ_ADFGVX)
    @key = ::SQKey.new(key, type)
  end # -- initialize

  # === decode
  #
  def decode(cipher_text)
    plain_text = ""
    
    ct = cipher_text.dup
    len = cipher_text.length / 2
    for i in 0..(len - 1) do
      bigram = ct.slice!(0,2) 
      pt = @key.decode(bigram)
      plain_text << pt
    end
    return plain_text
  end # -- decode
  
end # -- class Polybius

# == class Transposition
#
# Plain Transposition aka transposition
#
class Transposition < SimpleCipher
  def initialize(key)
    @key = TKey.new(key)
  end
  
  # === encode
  #
  def encode(text)
    #
    j = 0
    t_len = @key.length
    table = Array.new(t_len) { "" }
    cipher_text = ""
    
    tkey = @key.to_numeric
    #
    # XXX String.scan in 1.9, #each_byte?
    #
    text.scan(/./) do |pt|
      table[tkey[j]] << pt
      j = (j + 1) % t_len
    end
    #
    # Now take every column based upon key ordering
    #
    tkey.sort.each do |t|
      cipher_text << table[t]
    end
    return cipher_text
  end # -- encode
  
  # === decode
  #
  def decode(cipher_text)
    #
    # Look whether we are square or not
    #
    text = cipher_text.dup
    t_len = @key.length
    pad = text.length % t_len
    #
    # if pad is non-zero, last line is not finished by pad i.e.
    # columns pad-1 .. t_len-1 are shorter by 1
    #
    t_height = (text.length / t_len) + 1
    table = Array.new(t_len) { "" }
    plain_text = ""
    
    #puts "#{text.length} #{pad} #{t_height}"
    tkey = @key.to_numeric
    #
    # Fill in transposition board
    #
    for i in 0..(t_len - 1) do
      ind = tkey.index(i)
      how_many = t_height
      if ind > pad - 1 then
        how_many -= 1
      end
      ct = text.slice!(0, how_many)
      table[ind] << ct
      #puts "#{ct} #{how_many} #{ind} #{i}"
    end
    #
    # Now take the plain text
    #
    plain = ""
    for j in 0..(t_height - 1) do
      for i in 0..(t_len - 1) do
        col = table[i]
        plain << (col[j] || '')
      end
    end
    return plain
  end # -- decode
  
end # -- class Transposition

# == class Nihilist
#
# The Nihilist cipher has gone through several variations over the original
# version by the Russians nihilists.  Main characteristics is  the 
# checkerboard which shorten the cryptogram by having frequent letters use
# one letter as ciphertext and thus disturbing the recognition of 
# bigrams/monograms.
#
# The version used by USSR intelligence (aka spies) was using a super
# encryption by using an additive key (digit by digit without carryover)
#
# One possible variation would be having a transposition as supercipher.
# This is the one here.
#
class NihilistT
  attr_reader :super_key

  def initialize(key, super_key = "")
    @scb = SCKey.new(key)
    @super_key = Cipher::Transposition.new(super_key)
  end

  # === first_phase
  #
  def first_phase(plain_text)
    # First pass ciphertext
    #
    ct = ""
    
    pt = plain_text.dup
    pt.scan(/./) do |c|
      if c >= "0" and c <= "9" then
        ct << @scb.encode("/")
        ct << c + c
        ct << @scb.encode("/")
      end
      ct << @scb.encode(c)
    end
    return ct
  end # -- first_phase

  # === encode
  #
  def encode(plain_text)
    cipher_text = ""
    
    # First pass ciphertext
    #
    ct = first_phase(plain_text)
    cipher_text = @super_key.encode(ct)
    return cipher_text
  end # -- encode
  
  # === decode
  #
  def decode(cipher_text)
    plain_text = ""
    
    ct = @super_key.decode(cipher_text)
    while ct.length do
      c = ct.slice!(0,1)
      #
      # XXX US-ASCII hack
      #
      if @key.is_long?(c[0] - 65)
        c << ct.slice!(0,1)
      end
      pt = @key.decode(c)
      plain_text << pt
    end
    return plain_text
  end # -- decode
  
end # -- class NihilistT

# Implementation of the well known cipher used by Germany during
# WWI. Code number assignment is probably different from the original
# cipher due to implementation choices.
#
# See The Codebreakers, D. Kahn, 1996 for reference.
#     http://en.wikipedia.org/wiki/ADFGVX
#
class ADFGVX
  attr_reader :subst, :transp
  
  # === initialize
  #
  def initialize(key, super_key)
    @subst = Cipher::Polybius.new(key)
    @transp = Cipher::Transposition.new(super_key)
  end # -- initialize
  
  # === encode
  #
  def encode(text)
    ct = @subst.encode(text)
    cipher_text = @transp.encode(ct)
    return cipher_text
  end # -- encode(text)
  
  # === decode
  #
  def decode(text)
    pt = @transp.decode(text)
    plain_text = @subst.decode(pt)
    return plain_text
  end # -- decode
  
end # -- ADFGVX

end # -- module Cipher