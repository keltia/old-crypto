#
# $Id: cipher.rb,v 588bdffbc2b1 2010/08/04 15:35:56 roberto $

require "key"

module Cipher

# ==  SimpleCipher
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

#  Substitution
#
# Class for substitution cipher (Caesar, Polyalphabetic, Nihilist)
#
class Substitution < SimpleCipher
  attr_reader :key
  
  # === initialize
  #
  def initialize(key = "")
    @key = Key::SKey.new(key)
  end # -- initialize
  
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
  
end # --  Substitution

# ==  Caesar
#
# Caesar cipher, monoalphabetic substitution, offset is 3
#
class Caesar < Substitution
  
  # === initialize
  #
  def initialize(offset = 3)
    @key = Key::Caesar.new(offset)
  end # -- initialize
  
end # --  Caesar

# ==  Polybius
#
class Polybius < Substitution
  
  # === initialize
  #
  def initialize(key, type = Key::SQKey::SQ_ADFGVX)
    @key = Key::SQKey.new(key, type)
  end # -- initialize

  # === decode
  #
  def decode(cipher_text)
    raise ArgumentError, "Mangled cryptogram" if cipher_text.length.odd?
    
    plain_text = ""
    
    cipher_text.scan(/../) do |ct|
      pt = @key.decode(ct)
      plain_text << pt
    end
    return plain_text
  end # -- decode
  
end # --  Polybius

# == Playfair
#
# Bigrammatic substitution through a square alphabet
#
# Alphabet is missing Q by default
#
class Playfair < Substitution
  
  # === initialize
  #
  def initialize(key, type = Key::Playfair::WITH_Q)
    @key = Key::Playfair.new(key, type)
    @type = type
  end # -- substitution
  
  # === encode
  #
  def encode(plain_text)
    #
    # Do expand the double letters inside
    #
    plain = plain_text.expand
    
    # Add a "X" if of odd length
    #
    if plain.length.odd? then
      plain << "X"
    end
    
    check_input(plain)
    
    cipher_text = ""
    plain.scan(/../) do |pt|
      ct = @key.encode(pt)
      cipher_text << ct
    end
    cipher_text
  end # -- encode
  
  # === decode
  #
  def decode(cipher_text)
    raise ArgumentError, "Mangled cryptogram" if cipher_text.length.odd?
    
    check_input(cipher_text)
    
    plain_text = ""
    cipher_text.scan(/../) do |ct|
      pt = @key.decode(ct)
      plain_text << pt
    end
    plain_text
  end # -- decode
  
  # === check_input
  #
  def check_input(str)
    case @type
    when Key::Playfair::WITH_J
      raise ArgumentError if str =~ /Q/
    when Key::Playfair::WITH_Q
      raise ArgumentError if str =~ /J/
    end
  end # -- check_input
  
end # -- Playfair

# ==  Transposition
#
# Plain Transposition aka transposition
#
class Transposition < SimpleCipher
  def initialize(key)
    @key = Key::TKey.new(key)
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
  
end # --  Transposition

# ==  StraddlingCheckerboard
#
# This is the Straddling Checkerboard system (intended as a first pass to
# the Nihilist cipher and possibly others).
#
class StraddlingCheckerboard  < Substitution
  
  def initialize(key)
    @key = Key::SCKey.new(key)
  end

  # === encode
  #
  def encode(plain_text)
    cipher_text = ""
    
    pt = plain_text.dup
    pt.scan(/./) do |c|
      if c >= "0" and c <= "9" then
        cipher_text << @key.encode("/")
        cipher_text << c + c
        cipher_text << @key.encode("/")
      else
        cipher_text << @key.encode(c)
      end
    end
    return cipher_text
  end # -- encode

  # === decode
  #
  def decode(cipher_text)
    plain_text = ""

    ct = cipher_text.dup
    in_numbers = false
    while ct.length != 0 do
      c = ct.slice!(0,1)
      #
      # XXX US-ASCII hack
      #
      if RUBY_VERSION =~/1\.9/ then
        d = c.ord - 48
      else
        d = c[0] - 48
      end
      if @key.is_long?(d)
        c << ct.slice!(0,1)
      end
      pt = @key.decode(c)
      #
      # Number shift
      #
      if pt == "/" then
        if in_numbers then
          in_numbers = false
        else
          in_numbers = true
        end
      else
        if in_numbers then
          pt = ct.slice!(0,1)[0]
        end
        plain_text << pt
      end
    end
    return plain_text
  end # -- decode
  
end # --  StraddlingCheckerboard

# ==  Nihilist
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
class NihilistT < SimpleCipher
  attr_reader :super_key

  def initialize(key, super_key = "")
    @scb = Cipher::StraddlingCheckerboard.new(key)
    @super_key = Cipher::Transposition.new(super_key)
  end

  # === encode
  #
  def encode(plain_text)
    # First pass ciphertext
    #
    ct = @scb.encode(plain_text)
    cipher_text = @super_key.encode(ct)
    return cipher_text
  end # -- encode
  
  # === decode
  #
  def decode(cipher_text)
    ct = @super_key.decode(cipher_text)
    plain_text = @scb.decode(ct)
    return plain_text
  end # -- decode
  
end # --  NihilistT

# Implementation of the well known cipher used by Germany during
# WWI. Code number assignment is probably different from the original
# cipher due to implementation choices.
#
# See The Codebreakers, D. Kahn, 1996 for reference.
#     http://en.wikipedia.org/wiki/ADFGVX
#
class ADFGVX < SimpleCipher
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

class ChaoCipher < Substitution
  include Crypto
  
  attr_reader :key
  
  # === initialize
  #
  def initialize(pw, cw, flag = false)
    if flag then
      pw = keyshuffle(pw, Key::ChaoKey::BASE)
      cw = keyshuffle(cw, Key::ChaoKey::BASE)
    end
    @key = Key::ChaoKey.new(pw, cw)
  end # -- initialize
end # -- ChaoCipher

end # -- module Cipher