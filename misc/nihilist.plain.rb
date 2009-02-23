#! /usr/local/bin/ruby
#
# Copyright © 2001 by Ollivier Robert <roberto@keltia.freenix.fr>
#
# Implementation of the well known cipher used by Russian agents during
# WWII. Code number assignment is probably different from the original
# cipher due to implementation choices.
#
# See The Codebreakers, D. Kahn, 1996 for reference.
#
# Let our alphabet be ABCDEFGHIJKLMNOPQRSTUVWXYZ/-
#
# With key = SUBWAY, we form the following alphabet
#
# SUBWAYCDEFGHIJKLMNOPQRTVXZ/-
#
# in order to avoid sequential allocation of code #, we use the checkboard
# approach:
#
# Condensed key is SUBWAY
# Checkboard is
#
# SUBWAY
# CDEFGH
# IJKLMN
# OPQRTV
# XZ/-
#
# The final string will be
#
# SCIOXUDJPZBEKQ/WFLR-AGMTYHNV
#
# ESANTIRU will give the [0..7] pool in the order of appearance
# The rest of the letters are assigne 80..99.
#
# That would give us
# S = 0   C = 80  I = 1   O = 81  X = 82  U = 2   
# D = 83  J = 84  P = 85  Z = 86  B = 87  E = 3
# K = 88  Q = 89  / = 90  W = 91  F = 92  L = 93
# R = 4   - = 94  A = 5   G = 95  M = 96  T = 6   
# Y = 97  H = 98  N = 7   V = 99
#
# $Id$

## Forward and backward alphabet for ciphering/deciphering
##
$alpha = Hash.new
$ralpha = Hash.new

## Base alphabet
##
$base = "ABCDEFGHIJKLMNOPQRSTUVWXYZ/-"

## -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
## Condense word by removing every duplicated letter
##
def condense_word (word)
  c_alpha = ''

  word.scan (/./) {|c|
    if c_alpha !~ /#{c}/
      c_alpha = c_alpha + c
    end
  }
  c_alpha
end

## -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
## Assign a code number for each letter. Each code number is
## sequentially allocated from two pools, one with 0..7 and
## the other with 80..99.
##
## Allocation is made on the following criterias
## - if letter is one of ESANTIRU assign a single code number
## - else assign of of the two letters ones
##
## Generate both the encoding and decoding rings.
##

def code_word (word)
  ind_u = 0
  ind_d = 80

  word.scan (/./) {|c|
    if c =~ /[ESANTIRU]/
      $alpha[c] = ind_u
      $ralpha[ind_u] = c
      ind_u = ind_u + 1
    else
      $alpha[c] = ind_d
      $ralpha[ind_d] = c
      ind_d = ind_d + 1
    end
  }
end

## -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
## Shuffle the alphabet a bit to avoid sequential allocation of the
## code numbers
##
## Regular rectangle
## -----------------
## Key is ARABESQUE condensed into ARBESQU (len = 7) (height = 4)
## Let word be ARBESQUCDFGHIJKLMNOPTVWXYZ/-
##
## First passes will generate
##
## A  RBESQUCDFGHIJKLMNOPTVWXYZ/-   c=0  0 x 6
## AC  RBESQUDFGHIJKLMNOPTVWXYZ/-   c=6  1 x 6
## ACK  RBESQUDFGHIJLMNOPTVWXYZ/-   c=12 2 x 6
## ACKV  RBESQUDFGHIJLMNOPTWXYZ/-   c=18 3 x 6
## ACKVR  BESQUDFGHIJLMNOPTWXYZ/-   c=0  0 x 5
## ACKVRD  BESQUFGHIJLMNOPTWXYZ/-   c=5  1 x 5
## ...
## ACKVRDLWBFMXEGNYSHOZQIP/UJT-
##
## Irregular rectangle
## -------------------
## Key is SUBWAY condensed info SUBWAY (len = 6) (height = 5)
##
## S  UBWAYCDEFGHIJKLMNOPQRTVXZ/-   c=0  0 x 5
## SC  UBWAYDEFGHIJKLMNOPQRTVXZ/-   c=5  1 x 5
## SCI  UBWAYDEFGHJKLMNOPQRTVXZ/-   c=10 2 x 5
## SCIO  UBWAYDEFGHJKLMNPQRTVXZ/-   c=15 3 x 5
## SCIOX  UBWAYDEFGHJKLMNPQRTVZ/-   c=20 4 x 5
## SCIOXU  BWAYDEFGHJKLMNPQRTVZ/-   c=0  0 x 4
## ...
## SCIOXUDJPZBEKQ/WFLR-AG  YHMNTV   c=1  1 x 1
## SCIOXUDJPZBEKQ/WFLR-AGM  YHNTV   c=2  2 x 1
## SCIOXUDJPZBEKQ/WFLR-AGMT  YHNV   c=3  3 x 1
## SCIOXUDJPZBEKQ/WFLR-AGMTYHNV

def gen_checkbd (word, len)
  height = $base.length / len

  # Odd rectangle
  if ($base.length % len) != 0
    height = height + 1
  end

  print "checkboard size is #{len} x #{height}\n"
  res = ""
  (len - 1).downto (0) {|i|
    0.upto (height - 1) {|j|
      if word.length <= (height - 1)
        return res + word
      else
        c = word.slice! (i * j).chr
        res = res + c
      end
    }
  }
  return res
end 

## -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
## Generate the array with all code numbers allocated
##
def generate_checkbd (key)
  complete = key.upcase + $base

  c_alpha = condense_word (complete)
  c_key = condense_word (key).upcase

  print "condensed key     is #{c_key}\n"
  print "simple alphabet   is #{c_alpha}\n"

  c_alpha = gen_checkbd (c_alpha, c_key.length)

  print "modified alphabet is #{c_alpha}\n"
  code_word (c_alpha)
end

## -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
## Encode a given string using the code numbers. Numbers are
## converted to numbers before and put between //
##

def cipher_string (str)
  estr = str.gsub (/(\d+)/, '/\1/')
  estr.tr_s! (' ', '')

  print "#{str}\nis now\n#{estr}\n"

  crypto = ""
  estr.scan (/./) {|c|
    if c =~ /\d/
      crypto = crypto + c + c + c
    else
      crypto = crypto + ($alpha[c]).to_s
    end
  }
  crypto.gsub! (/(\d{5})/, '\1 ')
  return crypto
end

## XXX TEST XXX

word = ARGV[0].to_s.upcase
print "complete key      is #{word}\n"

generate_checkbd (word)

$alpha.keys.sort.each {|key|
  data = $alpha[key]
  r_data = $ralpha[data]
  print "#{key} = #{data}\t#{data} = #{r_data}\n"
}

clear = 'ABCEFGHIJKLMNOPQRSTUVWXZ0123456789'

crypto = cipher_string (clear)

print "clear = #{clear}\ncrypto = #{crypto}\n"

print "fin"

## -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
## Decode a stream of numbers into the proper cleartext
## Numbers are recognized and decoded as well
##
## Assumes that:
## - / has a two letter codeword
## - we use the standard encoding 0..7 = frequent letters
##

def decipher_string (str)
  estr = str.dup
  estr.gsub! (/ /, '')

  clear = ""
  estr.scan (/./) {|c|
    if c >= "0" and c <= "7"
      clear = clear + $ralpha[c].to_s
    else
      
# sub decipher_string ($)
# {
#     my $str = shift;
#     my $i = 0;
# 
#     $str =~ s< ><>g;
#     my $clear = '';
#     OUTER: while ($str ne '')
#     {
#         my $c = substr ($str, 0, 1);
#         $str = substr ($str, 1);
#         if ($c >= "0" && $c <= "7")
#         {
#             $clear .= $ralpha{"$c"};
#         }
#         else
#         {
#             ## Two-letter codeword
#             ## check for /
#             ##
#             my $d = substr ($str, 0, 1);
#             $str = substr ($str, 1);
# 
#             my $cl = $ralpha{"$c$d"};
#             if ($cl eq "/")
#             {
#                 ## we have numbers following.
#                 ##
#                 INNER: while (1)
#                 {
#                     my $cl1 = substr ($str, 0, 1);
#                     my $cl2 = substr ($str, 1, 1);
#                     $str = substr ($str, 2);
#                     last INNER
#                         if defined $ralpha{"$cl1$cl2"} and
#                            $ralpha{"$cl1$cl2"} eq "/";
# 
#                     my $cl3 = substr ($str, 0, 1);
#                     $str = substr ($str, 1);
# 
#                     last OUTER
#                         if $str eq '';
# 
#                     $clear .= $cl1
#                         if $cl1 == $cl2 and $cl2 == $cl3;
#                 }
#             }
#             else
#             {
#                 $clear .= $cl;
#             }
#         }
#     }
#     return $clear;
# }
# 
# ## -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# ## Main program
# ##
# die "Usage: $0 key\n"
#     if $#ARGV == -1;
# 
# generate_checkbd (shift)
#     if defined $ARGV[0];
# 
# foreach my $i (sort keys %alpha)
# {
#     print "$i => $alpha{$i}\n";
# }
# 
# ## XXX Should be fetched from command line XXX
# ##
# my $str = "ABCEFGHIJKLMNOPQRSTUVWXZ0123456789";
# 
# my $cipher = cipher_string $str;
# 
# print "cipher is\n$cipher\n";
# 
# my $clear = decipher_string $cipher;
# 
# print "clear text is\n$clear\n";
# 
# 
# 
# 
