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

end

M = 100_000
Benchmark.benchmark(' ' * 31 + Benchmark::Tms::CAPTION, 31) do |b|
  b.report("condensed") do
    M.times { "ANTICONSTITUTIONNELLEMENT".replace_double }
  end
  b.report("condensed1") do
    M.times { "ANTICONSTITUTIONNELLEMENT".replace_double1 }
  end
end

puts "ANTICONSTITUTIONNELLEMENT".replace_double
puts "ANTICONSTITUTIONNELLEMENT".replace_double1

  