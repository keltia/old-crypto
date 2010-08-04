# Design document
#
# $Id: README.txt,v 6eacd5db1203 2010/08/04 15:39:20 roberto $

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
	>	Transposition
	>	Nihilist
	>	ADFGX
	>	ADFGVX
	>	VIC
	>	SECOM
