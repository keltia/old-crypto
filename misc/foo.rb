#! /usr/bin/env ruby
#
require "cipher"
require "ap"

w = Cipher::Wheatstone.new("A", "CIPHER", "ADPWCFQXHGRYIJSZNKTELUMBOV")
p w.key.aplw
p w.key.actw
p w.encode("CHARLES+WHEATSTONE+HAD+A+REMARKABLY+FERTILE+MIND")

w = Cipher::Wheatstone.new("M", "CIPHER", "MACHINE")
p w.key.aplw
p w.key.actw
p w.encode("CHARLES+WHEATSTONE+HAD+A+REMARKABLY+FERTILE+MIND")

a = gets
w = Key::Wheatstone.new("M", "CIPHER", "MACHINE")
"BYVLQKWAMNLCYXIOUBFLHTXGHFPBJHZZLUEZFHIVBVRTFVRQ".each_char do |c|
  p "#{c} -> #{w.decode(c)}"
end

puts ""
