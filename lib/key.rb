#! /usr/bin/env ruby
#
# = key.rb various key handling classes
#
# Description:: Dealing with encryption keys
# Author:: Ollivier Robert <roberto@keltia.freenix.fr>
# Copyright:: © 2001-2009 by Ollivier Robert 
#
# $Id: key.rb,v 4a72faeea033 2013/03/10 18:23:32 roberto $

require 'key/base'
require 'key/chaokey'
require 'key/vickey'
require 'key/skey'
require 'key/caesar'
require 'key/playfair'
require 'key/sckey'
require 'key/sqkey'
require 'key/wheatstone'
require 'key/tkey'

class DataError < Exception
end

if $0 == __FILE__ then
  
  # several test keys
  #
  # square
  #
  k = Key::SCKey.new('ARABESQUE')
  p k.condensed
  
  # not square but known -- see above comments
  #
  m = Key::SCKey.new('subway')
  p m.condensed
  
  # not square
  #
  n = Key::SCKey.new('portable')
  p n.condensed

  # key for transposition
  #
  t = Key::TKey.new('retribution')
  #
  #
  # Main usage, get the numerical order of letters
  #
  p t.to_numeric

  exit(0)
end
