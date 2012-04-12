# $Id: test_crypto_helper.rb,v bd35b29bede2 2012/04/12 20:30:58 roberto $

require 'test/unit'
require "yaml"

require "crypto_helper"

# ==  TestString
#
class TestString < Test::Unit::TestCase
  include Crypto
  
  # === setup
  #
  def setup
    File.open("test/test_string.yaml") do |fh|
      @data = YAML.load(fh)
    end
  end # -- setup
  # === test_condensed
  #
  def test_condensed
    @data.keys.each do |word|
      assert_equal @data[word]["condensed"], word.condensed
    end
  end # -- test_condensed
  
  # === test_expand_double
  #
  def test_expand_double
    @data.keys.each do |word|
      assert_equal @data[word]["expanded"], word.expand
    end
  end # -- test_expand_double

  DATA_DOUBLE = {
    "ABCDE"         => "ABCDE",
    "COMMAND"       => "COMQAND",
    "MMMMMM"        => "MQMQMQ",
    "TIONNELLEMENT" => "TIONQELQEMENT",
  }

  # == test_replace_double
  def test_replace_double
    DATA_DOUBLE.each_pair do |word, data|
      assert_equal data, word.replace_double
    end
  end # -- test_replace_double

  # === test_to_numeric
  #
  def test_to_numeric
    @data.keys.each do |word|
      assert_equal @data[word]["num"], word.to_numeric
      assert_equal @data[word]["num"], word.to_numeric2 
      assert_equal @data[word]["num10"], word.to_numeric10
      assert_equal @data[word]["num10"], word.to_numeric11
    end
  end # -- test_to_numeric
  
  DATA_FIVE = {
    'ABC'        => 'ABC',
    'ABCDE'      => 'ABCDE',
    'ABCDEFGH'   => 'ABCDE FGH',
    'ABCDEFGHIJ' => 'ABCDE FGHIJ',
  }
    
  # === test_by_five
  #
  def test_by_five
    DATA_FIVE.each_pair do |text, out|
      assert_equal out, text.by_five
    end
  end # -- test_by_five
end # --  TestString

# ==  TestCrypto
#
class TestCrypto < Test::Unit::TestCase
  include Crypto
  
  # === setup
  #
  def setup
    File.open("test/test_crypto.yaml") do |fh|
      @data = YAML.load(fh)
    end
    @keys = @data["keys"]
  end # -- setup

  # === test_normalize
  #
  def test_normalize
    init = @data["init"]
    a = (init["phrase"][0..9]).to_numeric
    
    assert_not_nil a
    assert_equal Array, a.class
    
    res = normalize(a)
    
    assert_not_nil res
    assert_equal init["p1"], res
  end # -- test_normalize
  
  # === test_p1_encode
  #
  def test_p1_encode
    p1 = @data["p1"]
    in_p1 = p1["r1"]
    in_p2 = p1["r2"]
    exp = p1["r"]
    
    assert_equal Array, in_p1.class
    assert_equal Array, in_p2.class
    assert_equal Array, exp.class
    
    res = p1_encode(in_p1, in_p2)
    
    assert_not_nil res
    assert_equal exp, res
  end # -- test_p1_encode
  
  # === test_to_numeric
  #
  def test_to_numeric
    @num = @data["num"]
    a = @num["a"]
    b = @num["b"]

    assert_equal String, a.class
    assert_equal Array, b.class
    
    res = str_to_numeric(a)
    
    assert_not_nil res
    assert_equal b, res
  end # -- test_to_numeric
  
  # === test_chainadd
  #
  def test_chainadd
    @keys.keys.each do |ca|
      a = @keys[ca]["a"]
      b = @keys[ca]["b"]
      
      res = chainadd(a)
      
      assert_not_nil res
      assert_equal b, res, "#{ca} failed"
    end
  end # -- test_chainadd
  
  # === test_expand5to10
  #
  def test_expand5to10
    @expd = @data["expd"]
    expd = expand5to10(@expd["base"])
    
    assert_not_nil expd
    assert_equal @expd["5to10"], expd
  end # -- test_expand5to10
  
  # === test_addmod10
  #
  def test_addmod10
    test = @data["addmod"]
    a = test["a"]
    b = test["b"]
    
    assert a.length == b.length
    
    c = addmod10(a,b)
    
    assert_not_nil c
    assert_equal test["c"], c
  end # -- test_addmod10
  
  # === test_submod10
  #
  def test_submod10
    a = [ 7, 7, 6, 5, 1 ]
    b = [ 7, 4, 1, 7, 7 ]
    r = [ 0, 3, 5, 8, 4 ]
    
    res = submod10(a,b)
    
    assert_not_nil res
    assert_equal Array, res.class
    assert_equal r, res
  end # -- test_submod10
  
  # === test_find_hole
  #
  def test_find_hole
    ph = "AT ONE SIR"
    kw = "INDEPENDENCE"
    res = find_hole(kw, ph)
    assert_equal [1, 8], res
    
    ph = "ET AON RIS"
    kw = "ABCDEFGHIJ"
    res = find_hole(kw, ph)
    assert_equal [3, 7], res
    
    ph = "AT ONE SIR"
    kwn = [1, 2, 0 ,5, 3, 4, 8, 6, 7, 9]
    res = find_hole(kwn, ph)
    assert_equal [0, 8], res
  end # -- test_find_hole
  
  # === test_keyshuffle
  #
  def test_keyshuffle
    shf = @data["shuffle"]
    base = shf["base"]
    shf["keys"].each_pair do |k,r|
      res = keyshuffle(k, base)
    
      assert_not_nil res
      assert_equal String, res.class
      assert_equal r, res
    end
  end # -- test_keyshuffle

  def test_holearea
    a = HoleArea.new(0, 8, 5, 156)
    assert_equal [[0, 8], [0, 9], [0, 10], [0, 11], [0, 12], [1, 9], [1, 10], [1, 11], [1, 12], [2, 10], [2, 11],
                  [2, 12], [3, 11], [3, 12], [4, 12]], a.a

    b = HoleArea.new(5, 4, 9, 154)
    assert_equal [[5, 4], [5, 5], [5, 6], [5, 7], [5, 8], [5, 9], [5, 10], [5, 11], [5, 12], [6, 5], [6, 6], [6, 7],
                  [6, 8], [6, 9], [6, 10], [6, 11], [6, 12], [7, 6], [7, 7], [7, 8], [7, 9], [7, 10], [7, 11], [7, 12],
                  [8, 7], [8, 8], [8, 9], [8, 10], [8, 11], [8, 12], [9, 8], [9, 9], [9, 10], [9, 11], [9, 12], [10, 9],
                  [10, 10], [10, 11], [10, 12], [11, 10]], b.a
  end # -- test_holearea

end # --  TestCrypto
