# $Id: test_cipher.rb,v d158b3deab76 2009/03/12 18:41:38 roberto $

require 'test/unit'
require 'yaml'

require "key"
require "cipher"

module TestCipher

# ==  TestSimpleCipher
#
class TestSimpleCipher < Test::Unit::TestCase
  
  # === setup
  #
  def setup
    @cipher = Cipher::SimpleCipher.new
  end # -- setup
  
  # === test_init
  #
  def test_init
    assert_not_nil(@cipher)
  end # -- test_init
  
  # === test_encode
  #
  def test_encode
    ct = @cipher.encode("plain text")
    
    assert_not_nil(ct)
    assert_equal ct, "plain text"
  end # -- test_encode
  
  # === test_decode
  #
  def test_decode
    ct = @cipher.decode("plain text")
    
    assert_not_nil(ct)
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
  
  # === test_null_key
  #
  def test_null_key
    cipher = Cipher::Substitution.new()
    
    assert_not_nil cipher
  end # -- test_null_key
  
  # === test_encode_null
  #
  def test_encode_null
    cipher = Cipher::Substitution.new()

    pt = "TEST"
    ct = cipher.encode(pt)
    assert_not_nil(ct)
    assert_equal pt, ct, "Should degrade into 'give back plaintext'."
  end # -- test_encode_null
  
  # === test_encode_null
  #
  def test_decode_null
    cipher = Cipher::Substitution.new()

    ct = "TEST"
    pt = cipher.decode(ct)
    assert_not_nil(pt)
    assert_equal ct, pt, "Should degrade into 'give back plaintext'."
  end # -- test_decode_null
  
  # === test_both
  #
  def test_both
    cipher = Cipher::Substitution.new()
    
    assert_equal "PLAINTEXT", cipher.decode(cipher.encode("PLAINTEXT"))
  end # -- test_both
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
    assert_not_nil(ct)
    assert_equal ct, "DEFGH"
  end # -- test_encode
  
  def test_decode
    ct = "ABCDE"
    pt = @cipher.decode(ct)
    assert_not_nil(pt)
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
    assert_not_nil(ct)
    assert_equal ct, "HIJKL"
  end # -- test_encode
  
  def test_decode
    ct = "ABCDE"
    pt = @cipher.decode(ct)
    assert_not_nil(pt)
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
      assert_not_nil(cipher)
      ct = cipher.encode(pt)
      assert_not_nil(ct)
      assert_equal @keys[word]["ct"], ct, "key is #{word}"
    end
  end # -- test_encode
  
  # === test_decode
  #
  def test_decode
    plain = @data["plain"]
    @keys.keys.each do |word|
      cipher = Cipher::Transposition.new(word)
      assert_not_nil(cipher)
      pt = cipher.decode(@keys[word]["ct"])
      assert_not_nil(pt)
      assert_equal plain, pt, "key is #{word}" 
    end
  end # -- test_decode
end # --  TestTransposition

# ==  TestPlayfair
#
class TestPlayfair < Test::Unit::TestCase
  
  # === setup
  #
  def setup
    @data = Hash.new
    File.open("test/test_cipher_Playfair.yaml") do |fh|
      @data = YAML.load(fh)
    end
    @keys = @data["keys"]
  end # -- setup
  
  # === test_encode
  #
  def test_encode
    pt = @data["plain"]
    @keys.keys.each do |word|
      cipher = Cipher::Playfair.new(word, SQKey::SQ_NUMBERS)
      assert_not_nil(cipher)
      ct = cipher.encode(pt)
      assert_not_nil(ct)
      assert_equal @keys[word]["ct"], ct, "key is #{word}"
    end
  end # -- test_encode
  
  # === test_decode
  #
  def test_decode
    plain = @data["plain"]
    @keys.keys.each do |word|
      cipher = Cipher::Playfair.new(word, SQKey::SQ_NUMBERS)
      assert_not_nil(cipher)
      pt = cipher.decode(@keys[word]["ct"])
      assert_not_nil(pt)
      assert_equal plain, pt, "key is #{word}\ncipher is #{@keys[word]["ct"]}" 
    end
  end # -- test_decode
end # --  TestPlayfair

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
      assert_not_nil(cipher)
      ct = cipher.encode(pt)
      assert_not_nil(ct)
      assert_equal @keys[word]["ct"], ct, "key is #{word}"
    end
  end # -- test_encode
  
  # === test_decode
  #
  def test_decode
    plain = @data["plain"]
    @keys.keys.each do |word|
      cipher = Cipher::StraddlingCheckerboard.new(word)
      assert_not_nil(cipher)
      pt = cipher.decode(@keys[word]["ct"])
      assert_not_nil(pt)
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
      assert_not_nil(cipher)
      ct = cipher.encode(pt)
      assert_not_nil(ct)
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
      assert_not_nil(cipher)
      pt = cipher.decode(@keys[word]["ct"])
      assert_not_nil(pt)
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
      assert_not_nil(cipher)
      ct = cipher.encode(pt)
      assert_not_nil(ct)
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
      assert_not_nil(cipher)
      pt = cipher.decode(@keys[word]["ct"])
      assert_not_nil(pt)
      assert_equal plain, pt, "key is #{word}\ncipher is #{@keys[word]["ct"]}" 
    end
  end # -- test_decode
  
end # --  TestADFGVX

# ==  TestPlayfair
#
class TestPlayfair < Test::Unit::TestCase
  
  # === setup
  #
  def setup
    @data = Hash.new
    File.open("test/test_cipher_playfair.yaml") do |fh|
      @data = YAML.load(fh)
    end
    @keys = @data["keys"]
  end # -- setup
  
  # === test_encode
  #
  def test_encode
    pt = @data["plain"]
    @keys.keys.each do |word|
      cipher = Cipher::Playfair.new(word)
      assert_not_nil(cipher)
      ct = cipher.encode(pt)
      assert_not_nil(ct)
      assert_equal @keys[word]["ct"], ct, "key is #{word}"
    end
  end # -- test_encode
  
  # === test_decode
  #
  def test_decode
    plain = @data["plain"]
    @keys.keys.each do |word|
      cipher = Cipher::Playfair.new(word)
      assert_not_nil(cipher)
      pt = cipher.decode(@keys[word]["ct"])
      assert_not_nil(pt)
      assert_equal plain, pt, "key is #{word}\ncipher is #{@keys[word]["ct"]}" 
    end
  end # -- test_decode
end # --  TestPlayfair

end # -- TestCipher
