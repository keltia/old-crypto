# = key.rb
#
# Description:: Base virtual class
# Author:: Ollivier Robert <roberto@keltia.net>
# Copyright:: © 2001-2013 by Ollivier Robert 
#
# $Id: base.rb,v c824ad9444b6 2013/03/10 17:17:45 roberto $

module Key
  # == Key
  #
  # Virtual base class for keys
  #
  class Key
    attr_reader :key

    def initialize(key)
      raise ArgumentError if key.class != String and key.class != Fixnum
      if key.class == Fixnum then
        if key < 0 or key > 26 then
          raise RangeError
        end
      end
      @key = key.to_s.upcase
    end

    def to_s
      @key
    end

    # === condensed
    #
    def condensed
      @key.condensed
    end # -- condensed

    # === length
    #
    def length
      @key.length
    end # -- length

  end # -- Key
end # -- Key
