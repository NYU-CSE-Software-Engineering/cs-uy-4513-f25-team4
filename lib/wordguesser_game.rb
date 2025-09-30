class WordGuesserGame
  # add the necessary class methods, attributes, etc. here
  # to make the tests in spec/wordguesser_game_spec.rb pass.
  attr_accessor :word, :guesses, :wrong_guesses

  MAX_WRONG_GUESSES = 7

  # Get a word from remote "random word" service

  def initialize(word)
    @word = word
    @guesses = ''
    @wrong_guesses = ''
  end

  def guess(letter)
    raise ArgumentError if letter.nil? || letter.empty? || letter =~ /[^a-zA-Z]/

    letter.downcase!
    if @word.include?(letter)
      return false if @guesses.include?(letter)  # 重复猜
      @guesses << letter
      true
    else
      return false if @wrong_guesses.include?(letter)
      @wrong_guesses << letter
      true
    end
  end

  def word_with_guesses
    displayed_word = ""                  

    @word.chars.each do |char|       
      if @guesses.include?(char)
        displayed_word += char
      else
        displayed_word += "-"
      end
    end

    return displayed_word
  end

  def check_win_or_lose
    return :win if (@word.chars - @guesses.chars).empty?
    return :lose if @wrong_guesses.length >= MAX_WRONG_GUESSES
    :play
  end


  # You can test it by installing irb via $ gem install irb
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
