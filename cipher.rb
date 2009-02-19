#
# $Id: cipher.rb,v 790c7468c59e 2009/02/19 16:23:31 roberto $

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
  def decode(text)
  end # -- decode
  
end # -- class Transposition

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
  attr_reader :super_key
  
  def initialize(key, super_key)
    super(key)
    @super_key = TKey.new(super_key)
  end
end # -- ADFGVX

end # -- module Cipher