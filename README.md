# Design document
#
# $Id: README.md,v 651446246666 2011/12/23 20:45:10 roberto $

## Key handling

	Key => encrypt, decrypt
		SKey
		TKey
		SCKey
		ChaoKey

## Cipher handling

	module Cipher
	
	SimpleCipher => encode, decode
	>	Substitution
		>	ChaoCipher
		>   Caesar
		>   Rot13
	>	Transposition
	>	Nihilist
	>	ADFGX
	>	ADFGVX
	>	VIC
	>	SECOM
