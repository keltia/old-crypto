#
# $Id: cipher.rb,v eb14e9f512ac 2010/11/16 13:32:45 roberto $

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
    cipher_text = plain_text.each_char.inject("") do |text, pt|
      text + @key.encode(pt)
    end
  end # -- encode
  
  # === decode
  #
  def decode(cipher_text)
    plain_text = cipher_text.each_char.inject("") do |text, ct|
      text + @key.decode(ct)
    end
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

# == BiGrammatic
#
# Generic bigrammatic cipherclass
#
class BiGrammatic < Substitution

  # === initialize
  #
  def initialize(cipher, key, type)
    @key = cipher.send(:new, key, type)
    @type = type
  end # -- initialize

  # === decode
  #
  def decode(cipher_text)
    raise ArgumentError, "Mangled cryptogram" if cipher_text.length.odd?
    
    check_input(cipher_text) if @type == Key::Playfair::WITH_Q or
                                @type == Key::Playfair::WITH_J

    plain_text = cipher_text.scan(/../).inject('') do |text, ct|
      text + @key.decode(ct)
    end
  end # -- decode
  
  # === check_input
  #
  def check_input(str)
    case @type
    when Key::Playfair::WITH_J
      raise ArgumentError if str.include? ?Q
    when Key::Playfair::WITH_Q
      raise ArgumentError if str.include? ?J
    end
  end # -- check_input
  
end # -- BiGrammatic

# ==  Polybius
#
class Polybius < BiGrammatic
  
  # === initialize
  #
  def initialize(key, type = Key::SQKey::SQ_ADFGVX)
    super(Key::SQKey, key, type)
  end # -- initialize

end # --  Polybius

# == Playfair
#
# Bigrammatic substitution through a square alphabet
#
# Alphabet is missing Q by default
#
class Playfair < BiGrammatic
  
  # === initialize
  #
  def initialize(key, type = Key::Playfair::WITH_Q)
    super(Key::Playfair, key, type)
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
    
    cipher_text = plain.scan(/../).inject('') do |text, pt|
      text + @key.encode(pt)
    end
  end # -- encode
  
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
  def encode(plain_text)
    #
    j = 0
    t_len = @key.length
    table = Array.new(t_len) { "" }
    cipher_text = ""
    
    tkey = @key.to_numeric
    #
    # XXX String.scan in 1.9, #each_byte?
    #
    plain_text.scan(/./) do |pt|
      table[tkey[j]] << pt
      j = (j + 1) % t_len
    end
    #
    # Now take every column based upon key ordering
    #
    cipher_text = tkey.sort.each.inject("") do |text, t|
      text +  table[t]
    end
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
    cipher_text = plain_text.each_char.inject('') do |text, c|
      if c >= "0" and c <= "9" then
        text << @key.encode("/") << c + c << @key.encode("/")
      else
        text << @key.encode(c)
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

# == GenericBiCipher
#
# Generic framework class for ciphers using one cipher after another.
#
class GenericBiCipher < SimpleCipher
  attr_reader :key, :super_key

  def initialize(ch1, key, ch2, super_key = "")
    @subst = ch1.send(:new, key)
    @super_key = ch2.send(:new, super_key)
  end

  # === encode
  #
  def encode(plain)
    ct = @subst.encode(plain)
    cipher = @super_key.encode(ct)
  end # -- encode
  
  # === decode
  #
  def decode(cipher)
    ct = @super_key.decode(cipher)
    plain = @subst.decode(ct)
  end # -- decode
  
end

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
class NihilistT < GenericBiCipher

  # === initialize
  #
  def initialize(key, super_key = "")
    super(Cipher::StraddlingCheckerboard, key, Cipher::Transposition, super_key)
  end

end # --  NihilistT

# == ADFGVX
#
# Implementation of the well known cipher used by Germany during
# WWI. Code number assignment is probably different from the original
# cipher due to implementation choices.
#
# See The Codebreakers, D. Kahn, 1996 for reference.
#     http://en.wikipedia.org/wiki/ADFGVX
#
class ADFGVX <  GenericBiCipher

  # === initialize
  #
  def initialize(key, super_key = "")
    super(Cipher::Polybius, key, Cipher::Transposition, super_key)
  end # -- initialize
  
end # -- ADFGVX

# == ChaoCipher
#
# Cipher invented in 1917 but only recently released.
# See http://www.mountainvistasoft.com/chaocipher/index.htm
# Key schedule in lib/key.rb

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