# = wheatstone.rb
#
# Description:: Wheatstone cryptograph substitution key
# Author:: Ollivier Robert <roberto@keltia.net>
# Copyright:: © 2001-2013 by Ollivier Robert
#
# $Id: wheatstone.rb,v 3fc9059ea0b1 2013/03/10 18:11:53 roberto $

require 'key/skey'

module Key
  # == Wheatstone
  #
  # The Wheatstone cipher (not to be confused with Playfair, also from the author) is a
  # polyalphabetic stream cipher represented by a mechanical device with two synchronized
  # rotors just like a clock called the Wheatstone Cryptograph.
  #
  # For more details see
  # http://members.aon.at/cipherclerk/Doc/Whetstone.html
  # http://www.apprendre-en-ligne.net/crypto/instruments/index.html
  # http://bit.ly/983rDL
  #
  # All in all, this is a sliding system where the plain text "wheel/alphabet" slides over repetition
  # of the ciphertext wheel/alphabet.
  #
  class Wheatstone < SKey
    include Crypto

    attr_accessor :aplw, :actw, :curpos, :ctpos

    BASE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

    # == initialize
    #
    # Either we give full alphabets are keys or just words.
    # In the latter case, generate full alphabets as usual through #keyshuffle
    #
    def initialize(start, plw = BASE, ctw = BASE)
      super(start)
      if plw.length != BASE.length then
        #
        # Assume plw is a word we use as a base to generate an alphabet with #keyshuffle including space (as +)
        #
        plw = keyshuffle(plw, BASE)
      end
      plw = "+" + plw

      if ctw.length != BASE.length then
        #
        # Assume ctw is a word we use as a base to generate an alphabet with #keyshuffle
        #
        ctw = keyshuffle(ctw, BASE)
      end

      # We use array versions of the keys
      #
      @aplw = plw.each_char.to_a
      @actw = ctw.each_char.to_a

      # We always start at the space (named +) on plaintext
      #
      @curpos = 0

      # Starting letter for ciphertext is not the first one, set ctpos to its position
      #
      @ctpos = ctw.index(start)

      @l_aplw = @aplw.size
      @l_actw = @actw.size
    end # -- initialize

    def encode(c)
      a = @aplw.index(c)
      if a <= @curpos
        # we have made a turn
        off = (a + @l_aplw) - @curpos
      else
        off = a - @curpos
      end
      @curpos = a
      @ctpos = (@ctpos + off) % @l_actw
      @actw[@ctpos]
    end

    def decode(c)
      a = @actw.index(c)
      if a <= @ctpos
        # we have made a turn
        off = (a + @l_actw) - @ctpos
      else
        off = a - @ctpos
      end
      @ctpos = a
      @curpos = (@curpos + off) % @l_aplw
      @aplw[@curpos]
    end # -- decode

  end # -- Wheatstone
end # -- Key
