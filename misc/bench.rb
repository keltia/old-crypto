require "benchmark"

require "crypto_helper"

N = 100_000  
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

class String
  def condensed
    c_alpha = ''
    
    self.scan(/./) do |c|
      if not c_alpha.include?(c) then
        c_alpha = c_alpha + c
      end
    end
    c_alpha
  end # -- condensed
  
  def condensed1
    c_alpha = self.each_char.inject("") {|s,c|
      if s.include?(c)
        c=''
      end
      s+c
    }
  end # -- condensed
end

Benchmark.benchmark(' ' * 31 + Benchmark::Tms::CAPTION, 31) do |b|
  b.report("condensed") do
    N.times { "ANTICONSTITUTIONNELLEMENT".condensed }
  end
  b.report("condensed1") do
    N.times { "ANTICONSTITUTIONNELLEMENT".condensed1 }
  end
end

  