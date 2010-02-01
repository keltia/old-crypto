# Design document
#
# $Id: README.txt,v 24ca11af3b60 2010/02/01 14:32:54 roberto $

## Key handling

	Key => encrypt, decrypt
		SKey
		TKey
		SCKey

## Cipher handling

	module Cipher
	
	SimpleCipher => encode, decode
	>	Substitution
	>	Transposition
	>	Nihilist
	>	ADFGX
	>	ADFGVX
	>	VIC
	>	SECOM
