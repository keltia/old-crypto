require "benchmark"

require "crypto_helper"

N = 10_000  
Benchmark.benchmark(' ' * 31 + Benchmark::Tms::CAPTION, 31) do |b|  
  b.report('to_numeric') do  
    N.times { "ANTICONSTITUTIONNELLEMENT".to_numeric }  
  end  
  b.report('to_numeric2') do  
    N.times { "ANTICONSTITUTIONNELLEMENT".to_numeric2 }  
  end  
  b.report('to_numeric10') do  
    N.times { "ANTICONSTITUTIONNELLEMENT".to_numeric10 }  
  end  
  b.report('to_numeric11') do  
    N.times { "ANTICONSTITUTIONNELLEMENT".to_numeric11 }  
  end  
end

M = 100_000
Benchmark.benchmark(' ' * 31 + Benchmark::Tms::CAPTION, 31) do |b|
  b.report("condensed") do
    M.times { "ANTICONSTITUTIONNELLEMENT".condensed }
  end
end

class String
  def replace_double(letter = "Q")
    a_str = self.split(//)
    i = 0
    while i < a_str.length do
      if a_str[i] == a_str[i+1] then
        a_str[i+1] = letter
      end
      i += 1
    end
    a_str.join.to_s
  end # -- replace_double

  def replace_double1(letter = "Q")
    self.each_char.inject("") {|s,c|
      if s[-1] == c
        c = letter
      end
      s+c
    }
  end # -- replace_double

  def expand(letter = "X")
    a_str = self.split(//)
    i = 0
    while i < a_str.length do
      if a_str[i] == a_str[i+1] then
        a_str.insert(i+1, letter)
      end
      i += 2
    end
    a_str.join.to_s
  end # -- expand

  def expand1(letter = "X")
    self.scan(/../).inject("") {|s,c|
      if c[0] == c[1]
        c = c[0] + letter + c[1]
      end
      s+c
    }
  end
  
end

M = 100_000
Benchmark.benchmark(' ' * 20 + Benchmark::Tms::CAPTION, 20) do |b|
  b.report("replace_double") do
    M.times { "ANTICONSTITUTIONNELLEMENT".replace_double }
  end
  b.report("replace_double1") do
    M.times { "ANTICONSTITUTIONNELLEMENT".replace_double1 }
  end
end

puts "ANTICONSTITUTIONNELLEMENT".replace_double
puts "ANTICONSTITUTIONNELLEMENT".replace_double1

M = 100_000
Benchmark.benchmark(' ' * 20 + Benchmark::Tms::CAPTION, 20) do |b|
  b.report("expand") do
    M.times { "ANTICONSTITUTIONNELLEMENT".expand }
  end
  b.report("expand1") do
    M.times { "ANTICONSTITUTIONNELLEMENT".expand1 }
  end
end

puts "TIONNELLEMENTX".expand
puts "TIONNELLEMENTX".expand1

  