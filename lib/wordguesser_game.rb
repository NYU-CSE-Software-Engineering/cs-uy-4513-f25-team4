class WordGuesserGame
   # add the necessary class methods, attributes, etc.
  attr_accessor :word, :guesses, :wrong_guesses
  
  def initialize(word)
    @word = word
    @guesses = ''
    @wrong_guesses = ''
  end

  def guess(letter)
    raise ArgumentError if letter.nil? || letter.empty? || !letter.match(/[a-zA-Z]/)
    letter = letter.downcase
    return false if (@guesses + @wrong_guesses).include?(letter)
    
    if @word.downcase.include?(letter)
      @guesses += letter
    else
      @wrong_guesses += letter
    end
    
    return true
  end

  def word_with_guesses
    result = ""
    @word.each_char do |char|
      if @guesses.include?(char.downcase)
        result += char
      else
        result += '-'
      end
    end
    result
  end

  def check_win_or_lose
    word_letters = @word.downcase.chars.uniq
    guessed_letters = @guesses.chars
    if (word_letters - guessed_letters).empty?
      return :win
    elsif @wrong_guesses.length >= 7
      return :lose
    else
      return :play
    end
  end
  # You acan test it by installing irb via $ gem install irb 
  # and then running $ irb -I. -r app.rb  
  # And then in the irb: irb(main):001:0> WordGuesserGame.get_random_word  
  #  => "cooking"   <-- some random word

  def self.get_random_word
    require 'uri'
    require 'net/http'
    uri = URI('http://randomword.saasbook.info/RandomWord')
    Net::HTTP.new('randomword.saasbook.info').start do |http|
      return http.post(uri, "").body
    end
  end
end
