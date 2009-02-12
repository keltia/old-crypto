# $Id: test_key.rb,v 3c5d129b91c0 2009/02/12 21:16:18 roberto $

require 'test/unit'

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

  # === test_init
  #
  def test_init
    word = "arabesque"
    key = Key.new(word)
    assert_equal key.key, word.upcase
  end # -- test_init
  
  # === test_condensed1
  #
  def test_condensed1
    word = "ARABESQUE"
    key = Key.new(word)
    assert_equal key.condensed, "ARBESQU"
  end # -- test_condensed

  # === test_condensed2
  #
  def test_condensed2
    word = "SUBWAY"
    key = Key.new(word)
    assert_equal key.condensed, "SUBWAY"
  end # -- test_condensed2

  # === test_length
  #
  def test_length
    word = "ARABESQUE"
    key = Key.new(word)
    assert_equal key.length, word.length
  end # -- test_length
end # -- class TestKey

class TestTKey < Test::Unit::TestCase

  # === test_init
  #
  def test_init
    word = "arabesque"
    key = TKey.new(word)
    assert_equal key.key, word.upcase
  end # -- test_init
  
  # === test_to_numeric
  #
  def test_to_numeric
    word = "arabesque"
    key = TKey.new(word)
    assert_equal key.to_numeric, [0, 6, 1, 2, 3, 7, 5, 8, 4]
  end # -- test_to_numeric
  
  # === test_to_numeric2
  #
  def test_to_numeric2
    word = "arabesque"
    key = TKey.new(word)
    assert_equal key.to_numeric2, [0, 6, 1, 2, 3, 7, 5, 8, 4]
  end # -- test_to_numeric2
  
end # -- class TestTKey

class TestSCKey < Test::Unit::TestCase
  
  # === test_checkerboard
  #
  def test_checkerboard
    word = "arabesque"
    key = SCKey.new(word)
    assert_equal key.full_key, "ACKVRDLWBFMXEGNYSHOZQIP/UJT-"
    
    word = "subway"
    key = SCKey.new(word)
    assert_equal key.full_key, "SCIOXUDJPZBEKQ/WFLR-AGMTYHNV"
  end # -- test_checkerboard

end # -- class TestSCKey