# == Playfair
#
# Bigrammatic substitution through a square alphabet
#
# Alphabet is missing Q by default
#
class Playfair < BiGrammatic

  # === initialize
  #
  def initialize(key, type = Key::Playfair::WITH_Q)
    super(Key::Playfair, key, type)
  end # -- substitution

  # === encode
  #
  def encode(plain_text)
    #
    # Do expand the double letters inside
    #
    plain = plain_text.expand

    # Add a "X" if of odd length
    #
    if plain.length.odd? then
      plain << "X"
    end

    check_input(plain)

    cipher_text = plain.scan(/../).inject('') do |text, pt|
      text + @key.encode(pt)
    end
    return cipher_text
  end # -- encode

end # -- Playfair
