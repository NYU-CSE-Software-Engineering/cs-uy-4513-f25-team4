require 'capybara'
require 'selenium-webdriver'

# Configure Capybara to use Selenium for JavaScript scenarios
Capybara.default_driver = :rack_test
Capybara.javascript_driver = :selenium_chrome_headless

# Configure Selenium Chrome options
Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless=new')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--disable-gpu')
  options.add_argument('--remote-debugging-port=9222')

  # Explicitly set Chromium/Chromedriver paths for Docker images
  chrome_binary = ENV.fetch('CHROME_BIN', nil) || '/usr/bin/chromium' rescue '/usr/bin/chromium'
  options.binary = chrome_binary if File.exist?(chrome_binary)

  service = Selenium::WebDriver::Service.chrome(
    path: ENV.fetch('CHROMEDRIVER_PATH', '/usr/bin/chromedriver')
  )

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options, service: service)
end
