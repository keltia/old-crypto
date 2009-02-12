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
