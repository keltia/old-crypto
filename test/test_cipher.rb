# $Id: test_cipher.rb,v 1e38c6aef819 2009/03/05 11:11:04 roberto $

require 'test/unit'
require 'yaml'

require "key"
require "cipher"

module TestCipher
# ==  TestSimpleCipher
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
  
end # --  TestSimpleCipher

# ==  TestSubstitution
#
class TestSubstitution < Test::Unit::TestCase

  # === setup
  #
  def setup
    @cipher = Cipher::Substitution.new("FOOBAR")
  end # -- setup
  
  # === test_init
  #
  def test_init
    assert_not_nil(@cipher.key)
    assert_not_nil(@cipher.key.alpha)
    assert_not_nil(@cipher.key.ralpha)
  end # -- test_init
  
end # -- TestSubstitution

# ==  TestCipherCaesar
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
end # --  TestCipherCaesar

# ==  TestCipherCaesar7
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
end # --  TestCipherCaesar_7

# ==  TestTransposition
#
class TestTransposition < Test::Unit::TestCase

  # === setup
  #
  def setup
    @data = Hash.new
    File.open("test/test_cipher_transp.yaml") do |fh|
      @data = YAML.load(fh)
    end
    @keys = @data["keys"]
  end # -- setup
  
  # === test_encode
  #
  def test_encode
    pt = @data["plain"]
    @keys.keys.each do |word|
      cipher = Cipher::Transposition.new(word)
      ct = cipher.encode(pt)
      assert_equal @keys[word]["ct"], ct, "key is #{word}"
    end
  end # -- test_encode
  
  # === test_decode
  #
  def test_decode
    plain = @data["plain"]
    @keys.keys.each do |word|
      cipher = Cipher::Transposition.new(word)
      pt = cipher.decode(@keys[word]["ct"])
      assert_equal plain, pt, "key is #{word}" 
    end
  end # -- test_decode
end # --  TestTransposition

# ==  TestPolybius
#
class TestPolybius < Test::Unit::TestCase
  
  # === setup
  #
  def setup
    @data = Hash.new
    File.open("test/test_cipher_polybius.yaml") do |fh|
      @data = YAML.load(fh)
    end
    @keys = @data["keys"]
  end # -- setup
  
  # === test_encode
  #
  def test_encode
    pt = @data["plain"]
    @keys.keys.each do |word|
      cipher = Cipher::Polybius.new(word, SQKey::SQ_NUMBERS)
      ct = cipher.encode(pt)
      assert_equal @keys[word]["ct"], ct, "key is #{word}"
    end
  end # -- test_encode
  
  # === test_decode
  #
  def test_decode
    plain = @data["plain"]
    @keys.keys.each do |word|
      cipher = Cipher::Polybius.new(word, SQKey::SQ_NUMBERS)
      pt = cipher.decode(@keys[word]["ct"])
      assert_equal plain, pt, "key is #{word}\ncipher is #{@keys[word]["ct"]}" 
    end
  end # -- test_decode
end # --  TestPolybius

# ==  TestStraddlingCheckerboard
#
class TestStraddlingCheckerboard < Test::Unit::TestCase
  # === setup
  #
  def setup
    @data = Hash.new
    File.open("test/test_cipher_straddling.yaml") do |fh|
      @data = YAML.load(fh)
    end
    @keys = @data["keys"]
  end # -- setup
  
  # === test_encode
  #
  def test_encode
    pt = @data["plain"]
    @keys.keys.each do |word|
      cipher = Cipher::StraddlingCheckerboard.new(word)
      ct = cipher.encode(pt)
      assert_equal @keys[word]["ct"], ct, "key is #{word}"
    end
  end # -- test_encode
  
  # === test_decode
  #
  def test_decode
    plain = @data["plain"]
    @keys.keys.each do |word|
      cipher = Cipher::StraddlingCheckerboard.new(word)
      pt = cipher.decode(@keys[word]["ct"])
      assert_equal plain, pt, "key is #{word}\ncipher is #{@keys[word]["ct"]}" 
    end
  end # -- test_decode
  
end # --  TestStraddlingCheckerboard

# ==  TestNihilistT
#
class TestNihilistT < Test::Unit::TestCase
  # === setup
  #
  def setup
    @data = Hash.new
    File.open("test/test_cipher_nihilistt.yaml") do |fh|
      @data = YAML.load(fh)
    end
    @keys = @data["keys"]
  end # -- setup
  
  # === test_encode
  #
  def test_encode
    pt = @data["plain"]
    @keys.keys.each do |word|
      s, t = word.split(%r{,})
      cipher = Cipher::NihilistT.new(s, t)
      ct = cipher.encode(pt)
      assert_equal @keys[word]["ct"], ct, "key is #{word}"
    end
  end # -- test_encode
  
  # === test_decode
  #
  def test_decode
    plain = @data["plain"]
    @keys.keys.each do |word|
      s, t = word.split(%{,})
      cipher = Cipher::NihilistT.new(s, t)
      pt = cipher.decode(@keys[word]["ct"])
      assert_equal plain, pt, "key is #{word}\ncipher is #{@keys[word]["ct"]}" 
    end
  end # -- test_decode
  
end # --  TestNihilistT

# ==  TestADFGVX
#
class TestADFGVX < Test::Unit::TestCase
  
  # === setup
  #
  def setup
    @data = Hash.new
    File.open("test/test_cipher_adfgvx.yaml") do |fh|
      @data = YAML.load(fh)
    end
    @keys = @data["keys"]
  end # -- setup

  # === test_encode
  #
  def test_encode
    pt = @data["plain"]
    @keys.keys.each do |word|
      s, t = word.split(%r{,})
      cipher = Cipher::ADFGVX.new(s, t)
      ct = cipher.encode(pt)
      assert_equal @keys[word]["ct"], ct, "key is #{word}"
    end
  end # -- test_encode
  
  # === test_decode
  #
  def test_decode
    plain = @data["plain"]
    @keys.keys.each do |word|
      s, t = word.split(%{,})
      cipher = Cipher::ADFGVX.new(s, t)
      pt = cipher.decode(@keys[word]["ct"])
      assert_equal plain, pt, "key is #{word}\ncipher is #{@keys[word]["ct"]}" 
    end
  end # -- test_decode
  
end # --  TestADFGVX
end # -- TestCipher