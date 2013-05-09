[![Build Status](https://secure.travis-ci.org/keltia/old-crypto.png)](http://travis-ci.org/keltia/old-crypto)

# Design document

old-crypto (see [my site here](http://www.keltia.net/topics/cryptography/)) is a project to implement old paper-and-pencil crypto systems, used by different organizations, countries and individuals over the years.

## Key handling

    Key => encrypt, decrypt
	SKey
	TKey
	SCKey
	ChaoKey

## Cipher handling

    module Cipher
	
    SimpleCipher => encode, decode
	> Substitution
	 >   ChaoCipher
	 >   Caesar
	 >   Rot13
	 >   Wheatstone cryptograph
        > Transposition
	>	Nihilist
	>	ADFGX
	>	ADFGVX
	>	VIC
	>	SECOM
