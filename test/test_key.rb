# $Id: test_key.rb,v 839b8fc421fa 2009/03/05 13:56:07 roberto $

require 'test/unit'
require "yaml"

require "key"

# ==  TestString
#
class TestString < Test::Unit::TestCase

  # === test_condensed
  #
  def test_condensed
    assert_equal "ARBESQU", "ARABESQUE".condensed
    assert_equal "SUBWAY", "SUBWAY".condensed
    assert_equal "FO.BAR", "FOO.BAR".condensed
    assert_equal "FO?BAR", "FOO?BAR".condensed
  end # -- test_condensed

end # --  TestString

# ==  TestKey
#
class TestKey < Test::Unit::TestCase

  # === setup
  #
  def setup
    File.open("test/test_key.yaml") do |fh|
      @data = YAML.load(fh)
    end
  end # -- setup
  
  # === test_init
  #
  def test_init
    @data.keys.each do |word|
      key = Key.new(word)

      assert_not_nil key
      assert_equal key.key, word.upcase
    end
  end # -- test_init
  
  # === test_params
  #
  def test_params
    assert_raise(ArgumentError) { Key.new(nil)}
    assert_raise(ArgumentError) { Key.new(Array.new) }
    assert_nothing_raised(ArgumentError) { Key.new(3) }
    assert_nothing_raised(ArgumentError) { Key.new("") }
    assert_nothing_raised(ArgumentError) { Key.new("FOOBAR") }
    assert_raise(RangeError) { Key.new(42) }
  end # -- test_params
  
  # === test_condensed1
  #
  def test_condensed
    @data.keys.each do |word|
      key = Key.new(word)

      assert_not_nil key
      assert_equal key.condensed, @data[word]["condensed"]
    end
  end # -- test_condensed

  # === test_length
  #
  def test_length
    @data.keys.each do |word|
      key = Key.new(word)

      assert_not_nil key
      assert_equal key.length, word.length
    end
  end # -- test_length
  
end # --  TestKey

# == TestTKey
#
class TestTKey < Test::Unit::TestCase

  # === setup
  #
  def setup
    @data = Hash.new
    File.open("test/test_tkey.yaml") do |fh|
      @data = YAML.load(fh)
    end
  end # -- setup
  
  # === test_init
  #
  def test_init
    @data.keys.each do |word|
      key = TKey.new(word)

      assert_not_nil key
      assert_equal key.key, word.upcase
    end
  end # -- test_init
  
  # === test_to_numeric_1
  #
  def test_to_numeric_1
    @data.keys.each do |word|
      key = TKey.new(word)

      assert_not_nil key
      assert_equal key.to_numeric, @data[word]["num"]
    end
  end # -- test_to_numeric_1
  
  # === test_to_numeric_2
  #
  def test_to_numeric_2
    @data.keys.each do |word|
      key = TKey.new(word)

      assert_not_nil key
      assert_equal key.to_numeric2, @data[word]["num"]
    end
  end # -- test_to_numeric_2

  # === test_to_numeric_10
  #
  def test_to_numeric10
    @data.keys.each do |word|
      key = TKey.new(word)

      assert_not_nil key
      assert_equal key.to_numeric10, @data[word]["num10"]
    end
  end # -- test_to_numeric10
end # --  TestTKey

# ==  TestSKey
#
class TestSKey < Test::Unit::TestCase
  
  # === test_alpha
  #
  def test_presence_of_alpha
    word = "arabesque"
    key = SKey.new(word)

    assert_not_nil key      
    assert_not_nil key.alpha
    assert_not_nil key.ralpha
  end # -- test_presence_of_alpha
end # --  TestSKey

# ==  TestKeyCaesar
#
class TestKeyCaesar < Test::Unit::TestCase
  
  # === setup
  #
  def setup
    word = 3
    @key = Caesar.new(word)
    assert_not_nil @key
  end # -- setup
  
  # === test_alpha
  #
  def test_presence_of_alpha
    assert_not_nil @key.alpha
    assert_not_nil @key.ralpha
  end # -- test_presence_of_alpha
  
  # === test_alpha
  #
  def test_alpha
    @key.alpha.keys.each do |r|
      assert r =~ /[A-Z]/
    end
  end # -- test_alpha
  
  # === test_ralpha
  #
  def test_ralpha
    @key.ralpha.keys.each do |r|
      assert r =~ /[A-Z]/
    end
  end # -- test_alpha
  
  # === test_encode
  #
  def test_encode
    pt = "A"
    ct = @key.encode(pt)

    assert_not_nil ct
    assert_equal ct, "D"
    
    pt = "Y"
    ct = @key.encode(pt)

    assert_not_nil ct
    assert_equal ct, "B"
  end # -- test_encode
  
  # === test_decode
  #
  def test_decode
    ct = "D"
    pt = @key.decode(ct)

    assert_not_nil pt
    assert_equal pt, "A"
    
    ct = "C"
    pt = @key.decode(ct)

    assert_not_nil pt
    assert_equal pt, "Z"
  end # -- test_decode
end # --  TestKeyCaesar

# ==  TestSCKey
#
class TestSCKey < Test::Unit::TestCase
  
  # === setup
  #
  def setup
    File.open("test/test_sckey.yaml") do |fh|
      @data = YAML.load(fh)
    end
  end # -- setup
  
  # === test_alpha
  #
  def test_presence_of_alpha
    word = "arabesque"
    key = SCKey.new(word)

    assert_not_nil key
    assert_equal SCKey, key.class
    assert_not_nil key.alpha
    assert_not_nil key.ralpha
    assert_equal SCKey::BASE.length, key.alpha.length
    assert_equal SCKey::BASE.length, key.ralpha.length
  end # -- test_presence_of_alpha

  # === test_checkerboard
  #
  def test_checkerboard
    @data.keys.each do |word|
      key = SCKey.new(word)

      assert_not_nil key
      assert_not_nil key.full_key
      assert_equal SCKey::BASE.length, key.full_key.length
      assert_equal @data[word]["full_key"], key.full_key
    end
  end # -- test_checkerboard
  
  # === test_gen_rings
  #
  def test_gen_rings
    @data.keys.each do |word|
      key = SCKey.new(word)
    
      assert_not_nil key
      assert_equal @data[word]["alpha"], key.alpha
      assert_equal @data[word]["ralpha"], key.ralpha
    end
  end # -- test_gen_rings

  # === test_is_long
  #
  def test_is_long
    key = SCKey.new("arabesque")

    assert_not_nil key
    assert !key.is_long?(0)
    assert key.is_long?(9)
  end # -- test_is_long
  
  # === test_encode
  #
  def test_encode
    @data.keys.each do |word|
      key = SCKey.new(word)

      assert_not_nil key
      
      test = @data[word]["encode"]
      encode_in = test["in"]
      encode_out = test["out"]
      encode_in.each do |c|
        assert_equal encode_out.shift, key.encode(c)
      end
    end
  end # -- test_encode
  
  # === test_decode
  #
  def test_decode
    @data.keys.each do |word|
      key = SCKey.new(word)

      assert_not_nil key
      
      test = @data[word]["encode"]
      decode_in = test["out"]
      decode_out = test["in"]
      decode_in.each do |c|
        assert_equal decode_out.shift, key.decode(c)
      end
    end
  end # -- test_decode
end # --  TestSCKey

# ==  TestSQKey
#
class TestSQKey < Test::Unit::TestCase

  # === setup
  #
  def setup
    File.open("test/test_sqkey.yaml") do |fh|
      @data = YAML.load(fh)
    end
  end # -- setup

  # === test_gen_rings
  #
  def test_gen_rings
    @data.keys.each do |word|
      key = SQKey.new(word, @data[word]["type"])

      assert_not_nil key
      assert_equal key.class, SQKey
      assert_equal key.alpha, @data[word]["alpha"]
      assert_equal key.ralpha, @data[word]["ralpha"]
    end
  end # -- test_gen_rings

  # === test_encode
  #
  def test_encode
    @data.keys.each do |word|
      key = SQKey.new(word, @data[word]["type"])

      assert_not_nil key
      
      test = @data[word]["encode"]
      encode_in = test["in"]
      encode_out = test["out"]
      encode_in.each do |c|
        assert_equal encode_out.shift, key.encode(c), "#{word}"
      end
    end
  end # -- test_encode
  
  # === test_decode
  #
  def test_decode
    @data.keys.each do |word|
      key = SQKey.new(word, @data[word]["type"])

      assert_not_nil key
      
      test = @data[word]["encode"]
      encode_in = test["out"]
      encode_out = test["in"]
      encode_in.each do |ct|
        assert_equal encode_out.shift, key.decode(ct), "#{word}"
      end
    end
  end # -- test_decode
  
end # --  TestSQKey

# ==  TestVICKey
#
class TestVICKey < Test::Unit::TestCase

  # === setup
  #
  def setup
    File.open("test/test_vickey.yaml") do |fh|
      @data = YAML.load(fh)
    end
    @keys = @data["keys"]
  end # -- setup

  # === test_init
  #
  def test_init
    init = @data["init"]
    key = VICKey.new(init["ikey"], init["phrase"], init["imsg"])
    
    assert_not_nil key
    assert_not_nil key.first
    assert_not_nil key.second
    assert_not_nil key.third
    assert_not_nil key.sc_key
    
    assert_equal Array, key.p1.class
    assert_equal Array, key.p2.class
    assert_equal Array, key.first.class
    assert(key.first.length != 0)
    
    assert_equal init["p1"], key.p1
    assert_equal init["ikey5"], key.ikey5
    assert_equal init["first"], key.first
    assert_equal init["second"], key.second
    
    assert_equal init["third"], key.third
    assert_equal init["sc_key"], key.sc_key
  end # -- test_init

  # === test_normalize
  #
  def test_normalize
    init = @data["init"]
    a = TKey.new(init["phrase"][0..9]).to_numeric
    
    assert_not_nil a
    assert_equal Array, a.class
    
    res = VICKey.normalize(a)
    
    assert_not_nil res
    assert_equal init["p1"], res
  end # -- test_normalize
  
  # === test_p1_encode
  #
  def test_p1_encode
    init = @data["init"]
    p1 = @data["p1"]
    in_p1 = p1["r1"]
    in_p2 = p1["r2"]
    exp = p1["r"]
    
    assert_equal Array, in_p1.class
    assert_equal Array, in_p2.class
    assert_equal Array, exp.class
    
    res = VICKey.p1_encode(in_p1, in_p2)
    
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
    
    res = VICKey.to_numeric(a)
    
    assert_not_nil res
    assert_equal b, res
  end # -- test_to_numeric
  
  # === test_chainadd
  #
  def test_chainadd
    @keys.keys.each do |ca|
      a = @keys[ca]["a"]
      b = @keys[ca]["b"]
      
      res = VICKey.chainadd(a)
      
      assert_not_nil res
      assert_equal b, res, "#{ca} failed"
    end
  end # -- test_chainadd
  
  # === test_expand5to10
  #
  def test_expand5to10
    @expd = @data["expd"]
    expd = VICKey.expand5to10(@expd["base"])
    
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
    
    c = VICKey.addmod10(a,b)
    
    assert_not_nil c
    assert_equal test["c"], c
  end # -- test_addmod10
  
  # === test_submod10
  #
  def test_submod10
    a = [ 7, 7, 6, 5, 1 ]
    b = [ 7, 4, 1, 7, 7 ]
    r = [ 0, 3, 5, 8, 4 ]
    
    res = VICKey.submod10(a,b)
    
    assert_not_nil res
    assert_equal Array, res.class
    assert_equal r, res
  end # -- test_submod10
  
end # --  TestVICKey
