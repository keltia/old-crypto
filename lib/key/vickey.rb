# = vickey.rb
#
# Description:: VIC cipher substitution key
# Author:: Ollivier Robert <roberto@keltia.net>
# Copyright:: © 2001-2013 by Ollivier Robert
#
# $Id: vickey.rb,v f9e55abc2763 2013/03/10 18:19:19 roberto $

require 'key/base'

require 'key/base'

module Key
  # == VICKey
  #
  # The VIC cipher is described on the following Wikipedia page:
  # http://en.wikipedia.org/wiki/VIC_cipher
  #
  # and a working example is here:
  # http://www.hypermaths.org/quadibloc/crypto/pp1324.htm
  #
  # XXX Most of the arrays' content is 1-based mod 10 data
  # (i.e. 0 == 10 and 1 is the lowest)
  #
  # This uses a very complex key schedule as the basis of a straddling
  # checkerboard.
  #
  # Step1 uses Crypto.expand5to10
  # Step2 uses Crypto.chainadd on phrase (after conversion)
  # Step3 uses the previously calculated data by running it 5 times through
  # the Crypto.chainadd method.  The key thus calculated is then converted
  # through a transposition.
  #
  class VICKey < Key
    include Crypto

    attr_reader :first, :second, :third, :p1, :p2, :ikey5, :sc_key

    # === initialize
    #
    def initialize(ikey, phrase, imsg)
      #
      # First phase
      #
      @ikey5 = str_to_numeric(ikey[0..4])
      @imsg = str_to_numeric(imsg)
      res = submod10(@imsg, @ikey5)
      @first = expand5to10(res)
      #
      # Second phase: we take the long numeric keys in two parts but we *must*
      # use normalize because String#to_numeric uses 0-based arrays) XXX
      #
      # We split the key phrase into two 10 digits parts @p1 & @p2
      # Then we add mod 10 @p1 and the first expanded ikey (as @first)
      #
      @p1 = normalize(phrase[0..9].to_numeric)
      @p2 = normalize(phrase[10..19].to_numeric)
      tmp = addmod10(@first, @p1)
      @second = p1_encode(tmp, @p2)
      #
      # Third phase
      #
      # We run 5 times through chainadd
      #
      r = @second.dup
      5.times do
        r = chainadd(r)
      end
      @third = r
      @sc_key = @third.join.to_numeric
    end # -- initialize

  end # -- VICKey
end # -- Key
