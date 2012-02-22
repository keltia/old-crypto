# Design document
#
# $Id: README.md,v fad98edc60e0 2012/02/22 13:34:29 roberto $

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
		>   Wheatstone cryptograph
	>	Transposition
	>	Nihilist
	>	ADFGX
	>	ADFGVX
	>	VIC
	>	SECOM
