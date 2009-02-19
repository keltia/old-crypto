# $Id: test_cipher.rb,v 790c7468c59e 2009/02/19 16:23:31 roberto $

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
  
  # === setup
  #
  def setup
    @cipher = Cipher::Caesar.new
  end # -- setup
  
  # === test_encode
  #
  def test_encode
    pt = "ABCDE"
    ct = @cipher.encode(pt)
    assert_equal ct, "DEFGH"
  end # -- test_encode
  
  def test_decode
    ct = "ABCDE"
    pt = @cipher.decode(ct)
    assert_equal pt, "XYZAB"
  end
end # -- class TestCipherCaesar

# == class TestCipherCaesar7
#
class TestCipherCaesar7 < Test::Unit::TestCase
  
  # === setup
  #
  def setup
    @cipher = Cipher::Caesar.new(7)
  end # -- setup
  
  # === test_encode
  #
  def test_encode
    pt = "ABCDE"
    ct = @cipher.encode(pt)
    assert_equal ct, "HIJKL"
  end # -- test_encode
  
  def test_decode
    ct = "ABCDE"
    pt = @cipher.decode(ct)
    assert_equal pt, "TUVWX"
  end
end # -- class TestCipherCaesar_7
