# $Id: test_key.rb,v 4bcd9f836ba2 2009/03/03 13:25:33 roberto $

require 'test/unit'
require "yaml"

require "key"

# == class TestString
#
class TestString < Test::Unit::TestCase

  # === test_condensed1
  #
  def test_condensed1
    assert_equal "ARABESQUE".condensed, "ARBESQU"
  end # -- test_condensed

  # === test_condensed2
  #
  def test_condensed2
    assert_equal "SUBWAY".condensed, "SUBWAY"
  end # -- test_condensed2

end # -- class TestString

# == class TestKey
#
class TestKey < Test::Unit::TestCase

  # === setup
  #
  def setup
    @data = Hash.new
    File.open("test/test_key.yaml") do |fh|
      @data = YAML.load(fh)
    end
  end # -- setup
  
  # === test_init
  #
  def test_init
    @data.keys.each do |word|
      key = Key.new(word)
      assert_equal key.key, word.upcase
    end
  end # -- test_init
  
  # === test_condensed1
  #
  def test_condensed
    @data.keys.each do |word|
      key = Key.new(word)
      assert_equal key.condensed, @data[word]["condensed"]
    end
  end # -- test_condensed

  # === test_length
  #
  def test_length
    @data.keys.each do |word|
      key = Key.new(word)
      assert_equal key.length, word.length
    end
  end # -- test_length
  
end # -- class TestKey

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
      assert_equal key.key, word.upcase
    end
  end # -- test_init
  
  # === test_to_numeric_1
  #
  def test_to_numeric_1
    @data.keys.each do |word|
      key = TKey.new(word)
      assert_equal key.to_numeric, @data[word]["num"]
    end
  end # -- test_to_numeric_1
  
  # === test_to_numeric_2
  #
  def test_to_numeric_2
    @data.keys.each do |word|
      key = TKey.new(word)
      assert_equal key.to_numeric2, @data[word]["num"]
    end
  end # -- test_to_numeric_2

  # === test_to_numeric_10
  #
  def test_to_numeric10
    @data.keys.each do |word|
      key = TKey.new(word)
      assert_equal key.to_numeric10, @data[word]["num10"]
    end
  end # -- test_to_numeric10
end # -- class TestTKey

# == class TestSKey
#
class TestSKey < Test::Unit::TestCase
  
  # === test_alpha
  #
  def test_presence_of_alpha
    word = "arabesque"
    key = SKey.new(word)
    assert_not_nil key.alpha
    assert_not_nil key.ralpha
  end # -- test_presence_of_alpha
end # -- class TestSKey

# == class TestKeyCaesar
#
class TestKeyCaesar < Test::Unit::TestCase
  
  # === setup
  #
  def setup
    word = 3
    @key = Caesar.new(word)
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
    assert_equal ct, "D"
    
    pt = "Y"
    ct = @key.encode(pt)
    assert_equal ct, "B"
  end # -- test_encode
  
  # === test_decode
  #
  def test_decode
    ct = "D"
    pt = @key.decode(ct)
    assert_equal pt, "A"
    
    ct = "C"
    pt = @key.decode(ct)
    assert_equal pt, "Z"
  end # -- test_decode
end # -- class TestKeyCaesar

# == class TestSCKey
#
class TestSCKey < Test::Unit::TestCase
  
  # === setup
  #
  def setup
    @data = Hash.new
    File.open("test/test_sckey.yaml") do |fh|
      @data = YAML.load(fh)
    end
  end # -- setup
  
  # === test_alpha
  #
  def test_presence_of_alpha
    word = "arabesque"
    key = SCKey.new(word)
    assert_not_nil key.alpha
    assert_not_nil key.ralpha
  end # -- test_presence_of_alpha

  # === test_checkerboard
  #
  def test_checkerboard
    @data.keys.each do |word|
      key = SCKey.new(word)
      assert_equal @data[word]["full_key"], key.full_key
    end
  end # -- test_checkerboard
  
  # === test_gen_rings
  #
  def test_gen_rings
    @data.keys.each do |word|
      key = SCKey.new(word)
    
      assert_equal SCKey, key.class
      assert_equal @data[word]["alpha"], key.alpha
      assert_equal @data[word]["ralpha"], key.ralpha
    end
  end # -- test_gen_rings

  # === test_is_long
  #
  def test_is_long
    key = SCKey.new("arabesque")
    
    assert !key.is_long?(0)
    assert key.is_long?(9)
  end # -- test_is_long
  
  # === test_encode
  #
  def test_encode
    @data.keys.each do |word|
      key = SCKey.new(word)
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
      test = @data[word]["encode"]
      decode_in = test["out"]
      decode_out = test["in"]
      decode_in.each do |c|
        assert_equal decode_out.shift, key.decode(c)
      end
    end
  end # -- test_decode
end # -- class TestSCKey

# == class TestSQKey
#
class TestSQKey < Test::Unit::TestCase

  # === setup
  #
  def setup
    @data = Hash.new
    File.open("test/test_sqkey.yaml") do |fh|
      @data = YAML.load(fh)
    end
  end # -- setup

  # === test_gen_rings
  #
  def test_gen_rings
    @data.keys.each do |word|
      key = SQKey.new(word, @data[word]["type"])
    
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
      test = @data[word]["encode"]
      encode_in = test["out"]
      encode_out = test["in"]
      encode_in.each do |ct|
        assert_equal encode_out.shift, key.decode(ct), "#{word}"
      end
    end
  end # -- test_decode
  
end # -- class TestSQKey

# == class TestVICKey
#
class TestVICKey < Test::Unit::TestCase

  # === setup
  #
  def setup
    @data = Hash.new
    File.open("test/test_vickey.yaml") do |fh|
      @data = YAML.load(fh)
    end
    @expd = @data["expd"]
  end # -- setup

  # === test_key_schedule
  #
  def test_key_schedule
    false
#    @data.keys.each do |word|
#      ikey, phrase, imsg = word.split
#      key = VICKey.new(ikey, phrase, imsg)
#    end
  end # -- test_key_schedule
  
  # === test_expand5to10
  #
  def test_expand5to10
    key = VICKey.new
    expd = key.expand5to10(@expd["base"])
    assert_equal @expd["5to10"], expd
  end # -- test_expand5to10
  
end # -- class TestVICKey
