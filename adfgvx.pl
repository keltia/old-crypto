#! /usr/local/bin/perl -w
#
# Copyright © 1999 by Ollivier Robert <roberto@keltia.freenix.fr>
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
# $Id$

require 5.005;

use strict;

## Forward and backward alphabet for ciphering/deciphering
##
my %alpha;
my %ralpha;
my @t_key;
my $s_key;
my $t_key;

## Base alphabet
##
my $base = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

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
## Generate a numeric key from a keyword
##
## For each letter in the keyword, scan for the lowest letter, assign
## it an index # then scan again till there are no letter left
##
## Returns an array of tuples, one being the letter and the other its
## index.
##
## start: BESSON
## i_keyw -> [B,1],[E,2],[S,3],[S,4],[O,5],[N,6]
##
## sort:  BENOSS
## s_keyw -> [B,1],[E,2],[N,6],[O,5],[S,3],[S,4]
##
## calculate new indexes
## i_keyw -> [B,1],[E,2],[S,5],[S,6],[O,4],[N,3]
##
## index: 1 2 3 4 5 6
## key:   1 2 5 6 4 3
##
sub gen_numeric_key ($)
{
    my $word = shift;
    my @i_keyw = ();
    my @s_keyw = ();
    my $i = 0;

    ## Generate the initial hash
    ##
    ## XXX We generate the two hashes simultaneously to avoid having
    ##     cross-references between the two of them.
    ##
    while ($i < length $word)
    {
        my $c = substr ($word, $i, 1);
        $i_keyw[$i] = [ $c, $i + 1 ];
        $s_keyw[$i] = [ $c, $i + 1 ];
        $i++;
    }
    ## Sort it
    ##
    @s_keyw = sort { $a->[0] cmp $b->[0] } @s_keyw;

    $i = 0;
    my $entry;

    ## For each entry in @i_keyw, look into the sorted array @s_keyw
    ## and find the index
    ##
    OUTER: foreach $entry (@i_keyw)
    {
        my $j = 0;
        for ( ; $j < length $word; $j++ )
        {
            if ($entry->[0] eq $s_keyw[$j]->[0])
            {
                $entry->[1] = $j + 1;
                $s_keyw[$j]->[0] = '';
                next OUTER;
            }
        }
    }

    ## Generate numeric key
    ##
    my @num_key = ();
    foreach $entry (@i_keyw)
    {
        push @num_key, $entry->[1];
    }
    return @num_key;
}

## -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
## Generate a square ADFGVX board
##
## Generate the two series for enciphering and deciphering
##

my @ciph_letters = ( 'A', 'D', 'F', 'G', 'V', 'X' );

sub code_word ($)
{
    my $str = shift;  # condensed key+rest of alphabet
            
    for ( my $i = 0; $i <= 5; $i++ )
    {
        for ( my $j = 0; $j <= 5; $j++ )
        {
            my $c = '';
            
            $c = substr ($str, 0, 1);
            $str = substr ($str, 1);
            $alpha{"$c"} = "$ciph_letters[$i]$ciph_letters[$j]";
            $ralpha{"$ciph_letters[$i]$ciph_letters[$j]"} = "$c";
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

sub gen_checkbd ($)
{
    my $word = shift;    # ARBESQUCDFGHIJKLMNOPTVWXYZ/-
    my $len = 6;
    my $height = 6;

    my $res = "";

    my $i = 0;
    my $j = 0;

    OUT: for ( $i = $len - 1; $i >= 0 ; $i -- )     
    {
        for ( $j = 0; $j < $height ; $j ++ )
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

    $c_alpha = gen_checkbd ($c_alpha);

    print "modified alphabet is $c_alpha\n";
    code_word $c_alpha;
}

## -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
## Encode a given string using the code numbers.
##
## 1st phase of ADFGVX: encode with the checkboard
##
sub subst_string ($)
{
    my $str = shift;
    my $estr = $str;

    ## Remove any space
    ##
    $estr =~ s< ><>g;
#    print "$str\nis now\n$estr\n";

    my $crypto = "";

    while ($estr ne '')
    {
        my $c = substr ($estr, 0, 1);
        $estr = substr ($estr, 1);
        $crypto .= $alpha{$c};
    }
    return $crypto;
}

## -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
## Fill in the transposition table
##
## 2nd phase of ADFGVX
##
## XXX simple fill only for the moment, no "special" areas
##
sub cipher_string ($)
{
    my $clear = shift;

    my $s_cipher = subst_string $clear;

    print "1st cipher is\n$s_cipher\n";
    my $t_key_len = length $t_key;
    my $i = 0;
    my $j = 0;
    my $col;
    my %table = ();
    my $crypto = '';

    while ($s_cipher ne '')
    {
        my $c = '';

        $c = substr ($s_cipher, 0, 1);
        $s_cipher = substr ($s_cipher, 1);
        
        ## We must cheat a bit to get real numeric keys with 0+
        ## and protect ourselves against 'undef'.
        ##
        $table{0+ $t_key[$j]} = ($table{0+ $t_key[$j]} || '') . "$c";

        ## We are modulo the transposition key length
        ##
        $j = ($j + 1) % $t_key_len;
    }

    ## Get each column in order
    ##
    foreach $col (sort { $a <=> $b } keys %table)
    {
        $crypto .= $table{$col};
    }

    ## Cut down in 5 characters units
    ##
    $crypto =~ s<(\w{5})><$1 >g;
    return $crypto;
}

## -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
## Main program
##
die "Usage: $0 key1 key2 cleartext\n"
    if $#ARGV == -1;

$s_key = shift;
$t_key = shift;

generate_checkbd ($s_key);
@t_key = gen_numeric_key ($t_key);

my $clear = uc(shift);

#foreach my $i (keys %alpha)
#{
#    print "$i => $alpha{$i}\n";
#}

## XXX Should be fetched from command line XXX
##

my $cipher = cipher_string $clear;

print "cipher is\n$cipher\n";

#my $dclear = decipher_string $cipher;

#print "clear text is\n$dclear\n";



