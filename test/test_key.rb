# $Id: test_key.rb,v 39b7b840a7b7 2009/02/19 13:49:46 roberto $

require 'test/unit'
require "yaml"

require "key"

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
  
end # -- class TestTKey

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
      assert_equal key.full_key, @data[word]["full_key"]
    end
  end # -- test_checkerboard
  
  # === test_gen_rings
  #
  def test_gen_rings
    @data.keys.each do |word|
      key = SCKey.new(word)
    
      assert_equal key.class, SCKey
      assert_equal key.alpha, @data[word]["alpha"]
      assert_equal key.ralpha, @data[word]["ralpha"]
    end
  end # -- test_gen_rings

end # -- class TestSCKey