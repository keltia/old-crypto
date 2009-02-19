# $Id: test_cipher.rb,v e49cf56356a8 2009/02/19 16:22:34 roberto $

require 'test/unit'

require "key"
require "cipher"

# == class TestSimpleCipher
#
class TestSimpleCipher < Test::Unit::TestCase
  
  # === test_encode
  #
  def test_encode
    cipher = Cipher::SimpleCipher.new
    ct = cipher.encode("plain text")
    assert_equal ct, "plain text"
  end # -- test_encode
  
  # === test_decode
  #
  def test_decode
    cipher = Cipher::SimpleCipher.new
    ct = cipher.decode("plain text")
    assert_equal ct, "plain text"
  end # -- test_decode
  
end # -- class TestSimpleCipher

# == class TestCipherCaesar
#
class TestCipherCaesar < Test::Unit::TestCase
  
end # -- class TestSimpleCipher
