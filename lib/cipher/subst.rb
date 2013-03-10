# subst.rb
#
# Description:: Substitution ciphers base class
# Author:: Ollivier Robert <roberto@keltia.net>
# Copyright:: 2001-2013 © by Ollivier Robert
#
# $Id: subst.rb,v 886576ab2cda 2013/03/10 18:41:07 roberto $

require 'cipher/base'

module Cipher
  #  Substitution
  #
  # Class for substitution cipher (Caesar, Polyalphabetic, Nihilist)
  #
  class Substitution < SimpleCipher
    attr_reader :key

    # === initialize
    #
    def initialize(key = '')
      @key = Key::SKey.new(key)
    end # -- initialize

    # === encode
    #
    def encode(plain_text)
      cipher_text = plain_text.each_char.inject('') do |text, pt|
        text + @key.encode(pt)
      end
      return cipher_text
    end # -- encode

    # === decode
    #
    def decode(cipher_text)
      plain_text = cipher_text.each_char.inject('') do |text, ct|
        text + @key.decode(ct)
      end
      return plain_text
    end # -- decode

  end # --  Substitution
end # -- Cipher
