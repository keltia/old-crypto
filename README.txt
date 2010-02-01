# Design document

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
