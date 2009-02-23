#! /usr/local/bin/perl -w
#
# Copyright © 1999 by Ollivier Robert <roberto@keltia.freenix.fr>
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

require 5.005;

use strict;

## Forward and backward alphabet for ciphering/deciphering
##
my %alpha;
my %ralpha;

## Base alphabet
##
my $base = "ABCDEFGHIJKLMNOPQRSTUVWXYZ/-";

## -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
## Condense word by removing every duplicated letter
##
sub condense_word ($)
{
    my $word = shift;
    my $c_alpha = '';

    while ($word ne '')
    {
        my $c = substr ($word, 0, 1);
        $word = substr ($word, 1);
        $c_alpha .= $c
            if $c_alpha !~ /$c/;
    }
    return $c_alpha;
}

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
sub code_word ($)
{
    my $word = shift;
    my $ind_u = 0;
    my $ind_d = 80;

    my $c = '';

    while ($word ne '')
    {        
        $c = substr ($word, 0, 1);
        $word = substr ($word, 1);
        if ($c =~ /[ESANTIRU]/)
        {
            $alpha{$c} = $ind_u;
            $ralpha{$ind_u} = "$c";
            $ind_u++;
        }
        else
        {
            $alpha{$c} = $ind_d;
            $ralpha{$ind_d} = "$c";
            $ind_d++;
        }
    }
}

## -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
## Shuffle the alphabet a bit to avoid sequential allocation of the
## code numbers
##
## Key is ARABESQUE condensed into ARBESQU (len = 7)
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

sub gen_checkbd ($$)
{
    my $word = shift;    # ARBESQUCDFGHIJKLMNOPTVWXYZ/-
    my $len = shift;     # 7
    my $height = (length ($base) / $len) + ((length ($base) % $len) % 2);

    my $res = "";

    my $i = 0;
    my $j = 0;

    OUT: for ( $i = $len - 1; $i >= 0 ; $i -- )     
    {
        for ( $j = 0; $j <= $height ; $j ++ )
        {
            last OUT
                if $word eq '';
            my $c = substr ($word, $i * $j, 1, '');
            $res .= $c;
        }
    }
    return $res;
}

## -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
## Generate the array with all code numbers allocated
##
sub generate_checkbd ($)
{
    my $key = shift;

    my $complete = uc($key) . $base;

    my $c_alpha = condense_word $complete;
    my $c_key = uc(condense_word $key);

    print "condensed key     is $c_key\n";
    print "simple alphabet   is $c_alpha\n";

    my $len = length $c_key;
   
    $c_alpha = gen_checkbd ($c_alpha, $len);

    print "modified alphabet is $c_alpha\n";
    code_word $c_alpha;
}

## -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
## Encode a given string using the code numbers. Numbers are
## converted to numbers before and put between //
##

sub cipher_string ($)
{
    my $str = shift;
    my $estr = $str;

    $estr =~ s<(\d+)></$1/>gx;
    $estr =~ s< ><>g;
    print "$str\nis now\n$estr\n";

    my $crypto = "";

    while ($estr ne '')
    {
        my $c = substr ($estr, 0, 1);
        $estr = substr ($estr, 1);
        if ($c =~ /[0-9]/)
        {
            $crypto .= "$c$c$c";     # XXX double or triple ?
        }                            # Kahn says double but is ambiguous
        else
        {
            $crypto .= $alpha{$c};
        }
    }
    $crypto =~ s<(\d{5})><$1 >g;
    return $crypto;
}

## -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
## Decode a stream of numbers into the proper cleartext
## Numbers are recognized and decoded as well
##
## Assumes that:
## - / has a two letter codeword
## - we use the standard encoding 0..7 = frequent letters
##
sub decipher_string ($)
{
    my $str = shift;
    my $i = 0;

    $str =~ s< ><>g;
    my $clear = '';
    OUTER: while ($str ne '')
    {
        my $c = substr ($str, 0, 1);
        $str = substr ($str, 1);
        if ($c >= "0" && $c <= "7")
        {
            $clear .= $ralpha{"$c"};
        }
        else
        {
            ## Two-letter codeword
            ## check for /
            ##
            my $d = substr ($str, 0, 1);
            $str = substr ($str, 1);

            my $cl = $ralpha{"$c$d"};
            if ($cl eq "/")
            {
                ## we have numbers following.
                ##
                INNER: while (1)
                {
                    my $cl1 = substr ($str, 0, 1);
                    my $cl2 = substr ($str, 1, 1);
                    $str = substr ($str, 2);
                    last INNER
                        if defined $ralpha{"$cl1$cl2"} and
                           $ralpha{"$cl1$cl2"} eq "/";

                    my $cl3 = substr ($str, 0, 1);
                    $str = substr ($str, 1);

                    last OUTER
                        if $str eq '';

                    $clear .= $cl1
                        if $cl1 == $cl2 and $cl2 == $cl3;
                }
            }
            else
            {
                $clear .= $cl;
            }
        }
    }
    return $clear;
}

## -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
## Main program
##
die "Usage: $0 key\n"
    if $#ARGV == -1;

generate_checkbd (shift)
    if defined $ARGV[0];

foreach my $i (sort keys %alpha)
{
    print "$i => $alpha{$i}\n";
}

## XXX Should be fetched from command line XXX
##
my $str = "ABCEFGHIJKLMNOPQRSTUVWXZ0123456789";

my $cipher = cipher_string $str;

print "cipher is\n$cipher\n";

my $clear = decipher_string $cipher;

print "clear text is\n$clear\n";



