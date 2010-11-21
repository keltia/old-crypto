# Design document
#
# $Id$

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
