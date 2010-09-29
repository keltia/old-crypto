# $Id: test_cipher.rb,v e94ecb60adb4 2010/09/29 22:44:35 roberto $

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
      cipher = Cipher::Polybius.new(word, Key::SQKey::SQ_NUMBERS)
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
      cipher = Cipher::Polybius.new(word, Key::SQKey::SQ_NUMBERS)
      assert_not_nil(cipher)
      assert_raise(ArgumentError) { cipher.decode("AAA") }
      
      pt = cipher.decode(@keys[word]["ct"])
      assert_not_nil(pt)
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

# ==  TestPlayfair_J
#
class TestPlayfair_J < Test::Unit::TestCase
  
  # === setup
  #
  def setup
    File.open("test/test_cipher_playfair_j.yaml") do |fh|
      @data = YAML.load(fh)
    end
    @keys = @data["keys"]
  end # -- setup
  
  # === test_encode
  #
  def test_encode
    pt = @data["plain"]
    @keys.keys.each do |word|
      cipher = Cipher::Playfair.new(word, Key::Playfair::WITH_J)
      assert_not_nil(cipher)
      
      ct = cipher.encode(pt)
      assert_not_nil(ct)
      assert_equal @keys[word]["ct"], ct, "key is #{word}"
    end
  end # -- test_encode
  
  # === test_encode_padding
  #
  def test_encode_padding
    pt = "PJRST"
    cipher = Cipher::Playfair.new("FOOBAR", Key::Playfair::WITH_J)
    ct = cipher.encode(pt)
    assert_equal "WPBUSY", ct, "Text should be padded with X"
  end # -- test_encode_padding
  
  # === test_encode_invalid
  #
  def test_encode_invalid
    pt = "PQRJTS"
    cipher = Cipher::Playfair.new("FOOBAR", Key::Playfair::WITH_J)
    assert_raise(ArgumentError) { ct = cipher.encode(pt) }
  end # -- test_encode_invalid
    
  # === test_decode
  #
  def test_decode
    plain = @data["plain"]
    @keys.keys.each do |word|
      cipher = Cipher::Playfair.new(word, Key::Playfair::WITH_J)
      assert_not_nil(cipher)
      assert_raise(ArgumentError) { cipher.decode("AAA") }
      
      pt = cipher.decode(@keys[word]["ct"])
      assert_not_nil(pt)
      assert_equal plain, pt, "key: #{word}\ncipher: #{@keys[word]["ct"]}" 
    end
  end # -- test_decode
end # --  TestPlayfair_J

# ==  TestPlayfair_Q
#
class TestPlayfair_Q < Test::Unit::TestCase
  
  # === setup
  #
  def setup
    File.open("test/test_cipher_playfair_q.yaml") do |fh|
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
  
  # === test_encode_padding
  #
  def test_encode_padding
    pt = "PQRST"
    cipher = Cipher::Playfair.new("FOOBAR")
    ct = cipher.encode(pt)
    assert_equal "QSBUSY", ct, "Text is padded with X"
  end # -- test_encode_padding  

  # === test_encode_invalid
  #
  def test_encode_invalid
    pt = "PQRJTS"
    cipher = Cipher::Playfair.new("FOOBAR")
    assert_raise(ArgumentError) { ct = cipher.encode(pt) }
  end # -- test_encode_invalid
    
  # === test_decode
  #
  def test_decode
    plain = @data["plain"]
    eplain = @data["eplain"]
    @keys.keys.each do |word|
      cipher = Cipher::Playfair.new(word)
      assert_not_nil(cipher)
      assert_raise(ArgumentError) { cipher.decode("AAA") }
      
      pt = cipher.decode(@keys[word]["ct"])
      assert_not_nil(pt)
      assert_equal eplain, pt, "key: #{word}\ncipher: #{@keys[word]["ct"]}" 

    end
  end # -- test_decode
  
  # === test_decode_invalid
  #
  def test_decode_invalid
    ct = "PQRJTS"
    cipher = Cipher::Playfair.new("FOOBAR")
    assert_raise(ArgumentError) { pt = cipher.decode(ct) }
  end # -- test_decode_invalid
  
end # --  TestPlayfair_Q

class TestChaoCipher < Test::Unit::TestCase
  
  # === setup
  #
  def setup
    File.open("test/test_cipher_chao.yaml") do |fh|
      @data = YAML.load(fh)
    end
    @keys = @data["keys"]
  end # -- setup

  # === test_encode
  #
  def test_encode
    @keys.each_value do |type|
      pt = type["pt"]
      cw = type["cw"]
      pw = type["pw"]
      
      @key = Cipher::ChaoCipher.new(pw, cw)
      ct = @key.encode(pt)
      
      assert_equal type["ct"], ct
    end
  end # -- test_encode

  # === test_decode
  #
  def test_decode
    @keys.each_value do |type|
      ct = type["ct"]
      cw = type["cw"]
      pw = type["pw"]
      
      @key = Cipher::ChaoCipher.new(pw, cw)
      pt = @key.decode(ct)
      
      assert_equal type["pt"], pt
    end
  end # -- test_encode
end # -- TestChaoCipher

end # -- TestCipher
