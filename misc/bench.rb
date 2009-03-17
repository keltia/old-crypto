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
end  