#! /usr/local/bin/ruby
#
require "pp"

require "key"
require "cipher"

# === main
#
def main(argv)
  
  tr = Cipher::Transposition.new("arabesque")
  puts tr.encode("abcdefghijklmn")

  # Test cases for classes Skey & TKey
  #
  # several test keys
  #
  # square
  #
  k = SCKey.new("ARABESQUE")
  p k.condensed
  
  # not square but known -- see above comments
  #
  m = SCKey.new("subway")
  pp m.condensed
  
  # not square
  #
  n = SCKey.new("portable")
  pp n.condensed

  # key for transposition
  #
  t = TKey.new("retribution")
  #
  # A TKey is a Key as well
  #
  pp t.condensed
  #
  #
  # Main usage, get the numerical order of letters
  #
  pp t.to_numeric
  #
  return 0
end # -- main

if $0 == __FILE__ then
  exit(main(ARGV) || 1)
end

