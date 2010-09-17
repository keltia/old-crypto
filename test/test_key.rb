# $Id: test_key.rb,v 2fd65cc211d3 2010/09/17 15:44:19 roberto $

require 'test/unit'
require "yaml"

require "key"
require "crypto_helper"

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
      key = Key::Key.new(word)

      assert_not_nil key
      assert_equal key.key, word.upcase
    end
  end # -- test_init
  
  # === test_params
  #
  def test_params
    assert_raise(ArgumentError) { Key::Key.new(nil)}
    assert_raise(ArgumentError) { Key::Key.new(Array.new) }
    assert_nothing_raised(ArgumentError) { Key::Key.new(3) }
    assert_nothing_raised(ArgumentError) { Key::Key.new("") }
    assert_nothing_raised(ArgumentError) { Key::Key.new("FOOBAR") }
    assert_raise(RangeError) { Key::Key.new(42) }
  end # -- test_params
  
  # === test_condensed1
  #
  def test_condensed
    @data.keys.each do |word|
      key = Key::Key.new(word)

      assert_not_nil key
      assert_equal key.condensed, @data[word]["condensed"]
    end
  end # -- test_condensed

  # === test_length
  #
  def test_length
    @data.keys.each do |word|
      key = Key::Key.new(word)

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
      key = Key::TKey.new(word)

      assert_not_nil key
      assert_equal key.key, word.upcase
    end
  end # -- test_init
  
  # === test_to_numeric
  #
  def test_to_numeric
    @data.keys.each do |word|
      key = Key::TKey.new(word)

      assert_equal @data[word]["num"], key.to_numeric
    end
  end # -- test_to_numeric
end # --  TestTKey

# ==  TestSKey
#
class TestSKey < Test::Unit::TestCase
  
  # === test_alpha
  #
  def test_presence_of_alpha
    word = "arabesque"
    key = Key::SKey.new(word)

    assert_not_nil key      
    assert_not_nil key.alpha
    assert_not_nil key.ralpha
  end # -- test_presence_of_alpha

  # === test_encode_decode
  #
  def test_encode_decode
    key = Key::SKey.new("")
    
    assert_equal "P", key.decode("P")
    assert_equal "P", key.encode("P")
  end # -- test_encode_decode

end # --  TestSKey

# ==  TestKeyCaesar
#
class TestKeyCaesar < Test::Unit::TestCase
  
  # === setup
  #
  def setup
    word = 3
    @key = Key::Caesar.new(word)
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
    key = Key::SCKey.new(word)

    assert_not_nil key
    assert_equal Key::SCKey, key.class
    assert_not_nil key.alpha
    assert_not_nil key.ralpha
    assert_equal Key::SCKey::BASE.length, key.alpha.length
    assert_equal Key::SCKey::BASE.length, key.ralpha.length
  end # -- test_presence_of_alpha

  # === test_checkerboard
  #
  def test_checkerboard
    @data.keys.each do |word|
      key = Key::SCKey.new(word)

      assert_not_nil key
      assert_not_nil key.full_key
      assert_equal Key::SCKey::BASE.length, key.full_key.length
      assert_equal @data[word]["full_key"], key.full_key
    end
  end # -- test_checkerboard
  
  # === test_gen_rings
  #
  def test_gen_rings
    @data.keys.each do |word|
      key = Key::SCKey.new(word)
    
      assert_not_nil key
      assert_equal @data[word]["alpha"], key.alpha
      assert_equal @data[word]["ralpha"], key.ralpha
    end
  end # -- test_gen_rings

  # === test_is_long
  #
  def test_is_long
    key = Key::SCKey.new("arabesque")

    assert_not_nil key
    assert !key.is_long?(0)
    assert key.is_long?(9)
  end # -- test_is_long
  
  # === test_encode
  #
  def test_encode
    @data.keys.each do |word|
      key = Key::SCKey.new(word)

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
      key = Key::SCKey.new(word)

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

# == TestChaokey
#
class TestChaokey < Test::Unit::TestCase
  
  # === setup
  #
  def setup
    File.open("test/test_chaokey.yaml") do |fh|
      @data = YAML.load(fh)
    end

  end # -- setup

  # === test_advance
  #
  def test_advance
    a = Key::ChaoKey.new("PTLNBQDEOYSFAVZKGJRIHWXUMC",
                         "HXUCZVAMDSLKPEFJRIGTWOBNYQ")
    a.advance(12)
    assert_equal 26, a.plain.length
    assert_equal 26, a.cipher.length
    assert_equal "VZGJRIHWXUMCPKTLNBQDEOYSFA", a.plain
    assert_equal "PFJRIGTWOBNYQEHXUCZVAMDSLK", a.cipher
  end # -- test_advance
  
  # === test_encode
  #
  def test_encode
    false
  end # -- test_encode
  
  # === test_decode
  #
  def test_decode
    false
  end # -- test_decode
end # -- TestChaokey

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

  # === test_init
  #
  def test_init
    @data.keys.each do |word|
      key = Key::SQKey.new(word, @data[word]["type"])

      assert_not_nil key
      assert_equal @data[word]["full_key"], key.full_key
    end
  end # -- test_init
  
  # === test_gen_rings
  #
  def test_gen_rings
    @data.keys.each do |word|
      key = Key::SQKey.new(word, @data[word]["type"])

      assert_not_nil key
      assert_equal Key::SQKey, key.class
      assert_equal @data[word]["alpha"], key.alpha
      assert_equal @data[word]["ralpha"], key.ralpha
    end
  end # -- test_gen_rings

  # === test_encode
  #
  def test_encode
    @data.keys.each do |word|
      key = Key::SQKey.new(word, @data[word]["type"])

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
      key = Key::SQKey.new(word, @data[word]["type"])

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

# == TestPlayfair
#
class TestPlayfair_Q < Test::Unit::TestCase
  include Crypto
  
  # === setup
  #
  def setup
    File.open("test/test_playfair_q.yaml") do |fh|
      @data = YAML.load(fh)
    end
  end # -- setup

  # === test_init
  #
  def test_init
    @data.keys.each do |word|
      key = Key::Playfair.new(word)

      assert_not_nil key
      assert_equal Key::Playfair, key.class
      assert_not_nil key.alpha
      assert_not_nil key.ralpha
      assert_equal @data[word]["full_key"], key.full_key
    end
  end # -- test_init
  
  # === test_gen_rings
  #
  def test_gen_rings
    @data.keys.each do |word|
      key = Key::Playfair.new(word)

      assert_equal @data[word]["alpha"], key.alpha
      assert_equal @data[word]["ralpha"], key.ralpha
    end
  end # -- test_gen_rings
  
  # === test_encode
  #
  def test_encode
    @data.keys.each do |word|
      key = Key::Playfair.new(word)

      assert_not_nil key
      
      test = @data[word]["encode"]
      encode_in = test["in"]
      encode_out = test["out"]
      encode_in.each do |c|
        assert_equal encode_out.shift, key.encode(c), "#{word} #{c}"
      end
    end
  end # -- test_encode

  # === test_decode
  #
  def test_decode
    @data.keys.each do |word|
      key = Key::Playfair.new(word)

      assert_not_nil key
      
      test = @data[word]["encode"]
      encode_in = test["out"]
      encode_out = test["in"]
      encode_in.each do |ct|
        assert_equal encode_out.shift, key.decode(ct), "#{word} #{ct} "
      end
    end
  end # -- test_decode
end # -- TestPlayfair

# == TestWheatstone
#
class TestWheatstone < Test::Unit::TestCase
  include Crypto
  
  # === setup
  #
  def setup
  end # -- setup
  
end # -- TestWheatstone

# == TestPlayfair1
#
class TestPlayfair_J < Test::Unit::TestCase
  include Crypto
  
  # === setup
  #
  def setup
    File.open("test/test_playfair_j.yaml") do |fh|
      @data = YAML.load(fh)
    end
  end # -- setup

  # === test_init
  #
  def test_init
    @data.keys.each do |word|
      key = Key::Playfair.new(word, Key::Playfair::WITH_J)

      assert_not_nil key
      assert_equal Key::Playfair, key.class
      assert_not_nil key.alpha
      assert_not_nil key.ralpha
      assert_equal @data[word]["full_key"], key.full_key
    end
  end # -- test_init
  
  # === test_gen_rings
  #
  def test_gen_rings
    @data.keys.each do |word|
      key = Key::Playfair.new(word, Key::Playfair::WITH_J)

      assert_equal @data[word]["alpha"], key.alpha
      assert_equal @data[word]["ralpha"], key.ralpha
    end
  end # -- test_gen_rings
  
  # === test_encode
  #
  def test_encode
    @data.keys.each do |word|
      key = Key::Playfair.new(word, Key::Playfair::WITH_J)

      assert_not_nil key
      
      test = @data[word]["encode"]
      encode_in = test["in"]
      encode_out = test["out"]
      encode_in.each do |c|
        assert_equal encode_out.shift, key.encode(c), "#{word} #{c}"
      end
    end
  end # -- test_encode

  # === test_decode
  #
  def test_decode
    @data.keys.each do |word|
      key = Key::Playfair.new(word, Key::Playfair::WITH_J)

      assert_not_nil key
      
      test = @data[word]["encode"]
      encode_in = test["out"]
      encode_out = test["in"]
      encode_in.each do |ct|
        assert_equal encode_out.shift, key.decode(ct), "#{word} #{ct} "
      end
    end
  end # -- test_decode
end # -- TestPlayfair_J

# ==  TestVICKey
#
class TestVICKey < Test::Unit::TestCase
  include Crypto
  
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
    key = Key::VICKey.new(init["ikey"], init["phrase"], init["imsg"])
    
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

end # --  TestVICKey
