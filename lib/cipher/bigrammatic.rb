# bigrammatic.rb
#
# Description:: Base bigrammatic cipher
# Author:: Ollivier Robert <roberto@keltia.net>
# Copyright:: 2001-2013 © by Ollivier Robert
#
# XXX knows about Playfair
#
# $Id: bigrammatic.rb,v 07f48879a407 2013/03/10 18:59:22 roberto $


require 'key/playfair'
require 'cipher/subst'

module Cipher

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
      raise ArgumentError, 'Mangled cryptogram' if cipher_text.length.odd?

      check_input(cipher_text) if @type == Key::Playfair::WITH_Q or
          @type == Key::Playfair::WITH_J

      plain_text = cipher_text.scan(/../).inject('') do |text, ct|
        text + @key.decode(ct)
      end
      return plain_text
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
end # -- Cipher
