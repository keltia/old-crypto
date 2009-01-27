
class Cipher
  attr_reader :key
  
  def initialize(key)
    @key = Key.new(key)
  end

  # === forward
  #
  def forward
    @key.alpha.keys.sort.each do |k|
      v = @key.alpha[k].to_i
      yield k, v
    end
  end # -- forward

  # === reverse
  #
  def reverse
    @key.ralpha.keys.sort.each do |k|
      v = @key.ralpha[k].to_s
      yield k, v
    end
  end # -- reverse


end # -- class Cipher

class Nihilist < Cipher
  attr_reader :super_key

  def initialize(key, super_key = "")
    super(key)
    complete = ''
    complete = (@key.to_s.upcase + BASE).condense_word
    code_word(gen_checkbd(complete, @key.to_s.length))
    @super_key = super_key
  end

  private

end # -- class Nihilist
