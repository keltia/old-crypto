#
# $Id: cipher.rb,v e554d04c10ed 2013/03/10 19:05:48 roberto $

require 'key'

require 'cipher/base'
require 'cipher/subst'
require 'cipher/bigrammatic'
require 'cipher/playfair'
require 'cipher/polybius'
require 'cipher/caesar'
require 'cipher/rot13'

module Cipher

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
    table = Array.new(t_len) { '' }
    cipher_text = ''
    
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
    cipher_text = tkey.sort.each.inject('') do |text, t|
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
    table = Array.new(t_len) { '' }
    plain_text = ''
    
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
    for j in 0..(t_height - 1) do
      for i in 0..(t_len - 1) do
        col = table[i]
        plain_text << (col[j] || '')
      end
    end
    return plain_text
  end # -- decode
  
end # --  Transposition

# == DisruptedTransposition
#
# This is a complicated transposition scheme where several areas are ignored at initial filling according to
# the keyword then filled up later in the second phase.
#
# See: http://www.quadibloc.com/crypto/pp1324.htm
#      http://users.telenet.be/d.rijmenants/en/handciphers.htm
#
class DisruptedTransposition < SimpleCipher
  include Crypto

  attr_reader :key, :nkey, :lkey

  def initialize(key)
    @key = Key::TKey.new(key)
    @nkey = @key.to_numeric
    @lkey = @nkey.size
  end

  # === encode
  #
  def encode(plain_text)
    @msglen = plain_text.length
    holes = compute_holes(@msglen)

    j = 0
    t_len = @key.length
    table = Array.new(t_len) { '' }
    cipher_text = ''

    # 1st phase: fill in everything else than a hole
    #
    plain = plain_text.each_char.to_a
    for i in 0..(@msglen - 1) do
      pt = plain.shift
      #print "pt: #{pt} #{[i / t_len,j]} @nkey[#{j}]: #{@nkey[j]} "
      if holes.include?([i / t_len,j])
        table[@nkey[j]] << '.'
        plain.unshift(pt)
      else
        table[@nkey[j]] << pt
      end
      #puts " table[#{@nkey[j]}]: #{table[@nkey[j]]}"
      j = (j + 1) % t_len
    end

    # 2nd phase: fill in all holes
    #
    holes.each do |e|
      row = e[0]
      col = @nkey[e[1]]

      p = plain.shift
      curcol = table[col]
      curcol[row] = p
      #puts("holes: #{row},#{col} -> #{p} curcol: #{curcol}")
    end

    # Now take every column based upon key ordering
    #
    cipher_text = @nkey.sort.each.inject('') do |text, t|
      text +  table[t]
    end
  end # -- encode

  # === decode
  #
  # XXX to be completed
  #
  def decode
    @msglen = plain_text.length
    holes = compute_holes(@msglen)

  end # -- decode

  # === compute_holes
  #
  # Compute the list of cells to be ignored in first filling phase
  #
  def compute_holes(len)
    #
    # We have potentially as many holes as we have key letters
    # but we have a much more simple stop condition, that is, the last
    # hole is incomplete
    #
    # Return the list of unavailable [x,y] (i.e. all areas merged)
    #
    holes = Array.new
    start_row = 0
    start_x = 0
    loop do
      pos = @nkey.index(start_x)
      hole = HoleArea.new(start_row, pos, @lkey - pos, len)
      holes << hole.a
      break unless hole.complete?
      start_x += 1
      start_row = start_row + hole.ylen
    end
    holes.flatten(1)
  end # -- compute_holes

end # -- DisruptedTransposition

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
      if c >= '0' and c <= '9' then
        text << @key.encode('/') << c + c << @key.encode('/')
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
      d = c.ord - 48
      if @key.is_long?(d)
        c << ct.slice!(0,1)
      end
      pt = @key.decode(c)
      #
      # Number shift
      #
      if pt == '/' then
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

  def initialize(ch1, key, ch2, super_key = '')
    @subst = ch1.send(:new, key)
    @super_key = ch2.send(:new, super_key)
  end

  # === encode
  #
  def encode(plain)
    return @super_key.encode(@subst.encode(plain))
  end # -- encode
  
  # === decode
  #
  def decode(cipher)
    return @subst.decode(@super_key.decode(cipher))
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
  def initialize(key, super_key = '')
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
  def initialize(key, super_key = '')
    super(Cipher::Polybius, key, Cipher::Transposition, super_key)
  end # -- initialize
  
end # -- ADFGVX

# == Wheatstone
#
class Wheatstone < Substitution
  include Crypto

  # === initialize
  #
  def initialize(start, plain, cipher)
    @key = Key::Wheatstone.new(start, plain, cipher)
  end # -- initialize

  # === encode
  #
  def encode(plain_text)
    #
    # Doubled letters cc should be replaced by cQ
    #
    pl = plain_text.replace_double('Q')
    cipher_text = pl.each_char.inject('') do |text, pt|
      text + @key.encode(pt)
    end
    cipher_text
  end # -- encode

end # -- Wheatstone

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