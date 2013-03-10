#! /usr/bin/env ruby
#
# = key.rb various key handling classes
#
# Description:: Dealing with encryption keys
# Author:: Ollivier Robert <roberto@keltia.freenix.fr>
# Copyright:: © 2001-2009 by Ollivier Robert 
#
# $Id: key.rb,v 2c285ab71d4e 2013/03/10 18:24:53 roberto $

class DataError < Exception
end

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
