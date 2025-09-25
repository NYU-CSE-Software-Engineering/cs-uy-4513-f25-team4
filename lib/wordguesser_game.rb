class WordGuesserGame
   # add the necessary class methods, attributes, etc. 
   #
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
