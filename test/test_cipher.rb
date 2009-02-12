# $Id: test_cipher.rb,v 2371e41abf17 2009/02/12 23:25:02 roberto $

require 'test/unit'

require "cipher"

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
