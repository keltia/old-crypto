#
# $Id: cipher.rb,v d27736fd846b 2009/02/21 14:23:30 roberto $

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
class Nihilist
  attr_reader :super_key

  def initialize(key, super_key = "")
    super(key)
    complete = ''
    complete = (@key.to_s.upcase + BASE).condense_word
    code_word(gen_checkbd(complete, @key.to_s.length))
    @super_key = TKey.new(super_key)
  end

  private

end # -- class Nihilist

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