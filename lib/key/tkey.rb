# = key.rb
#
# Description:: Transposition key
# Author:: Ollivier Robert <roberto@keltia.net>
# Copyright:: © 2001-2013 by Ollivier Robert
#
# $Id: tkey.rb,v 630720bb99e5 2013/03/10 17:23:35 roberto $

require 'key/base'

module Key
  # == TKey
  #
  #  Class for transposition keys
  #
  # A transposition key does not get condensed but serve as a generator for
  # a numeric key based on letters.  Later on, these numbers will be used to
  # extract columns.
  #
  # See http://en.wikipedia.org/wiki/Transposition_cipher

  class TKey < Key
    include Crypto

    def initialize(key)
      super(key)
    end

    # === to_numeric
    #
    def to_numeric
      @key.to_numeric
    end # -- to_numeric

  end # -- TKey
end # -- Key
