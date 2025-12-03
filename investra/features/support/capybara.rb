require 'capybara'
require 'selenium-webdriver'

# Configure Capybara to use Selenium for JavaScript scenarios
Capybara.default_driver = :rack_test
Capybara.javascript_driver = :selenium_chrome_headless

# Configure Selenium Chrome options
Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--disable-gpu')
  
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

