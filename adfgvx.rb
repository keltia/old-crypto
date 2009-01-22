#! /usr/local/bin/ruby
#
# Copyright © 2000 by Ollivier Robert <roberto@keltia.freenix.fr>
#
# Implementation of the well known cipher used by Germany during
# WWI. Code number assignment is probably different from the original
# cipher due to implementation choices.
#
# See The Codebreakers, D. Kahn, 1996 for reference.
#
# Let our alphabet be ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789
#
# With key = SUBWAY, we form the following alphabet
#
# SUBWAYCDEFGHIJKLMNOPQRTVXZ0123456789
#
# Checkboard is
#
#   ADFGVX
# A SUBWAY
# D CDEFGH
# F IJKLMN
# G OPQRTV
# V XZ0123
# X 456789
#
# From the second key we generate a transposition key
#
# BESSON give us [ 1 2 5 6 4 3 ] (see below)
#
# BUGS:
#       The five letters version without numbers is not implemented
#
# $Id: adfgvx.rb,v 96ed61ae8961 2009/01/22 15:25:51 roberto $

$base = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

def condense_word(word)
  c_alpha = ''
  word.each_byte{|c|
    c_alpha = c_alpha+c.to_s if c_alpha !~ /#{c}/
  }
  return c_alpha
end


      
