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

  # Try multiple possible chromedriver paths
  chromedriver_path = nil
  possible_paths = [
    ENV['CHROMEDRIVER_PATH'],
    '/opt/homebrew/bin/chromedriver',  # macOS Homebrew (Apple Silicon)
    '/usr/local/bin/chromedriver',     # macOS Homebrew (Intel)
    '/usr/bin/chromedriver',
    File.expand_path('~/.local/bin/chromedriver'),  # User local bin
    File.expand_path('~/bin/chromedriver')  # User bin
  ].compact
  
  # Try to find chromedriver in PATH as fallback
  begin
    which_result = `which chromedriver 2>/dev/null`.strip
    possible_paths << which_result if which_result.present? && File.exist?(which_result)
  rescue
    # Ignore errors from which command
  end
  
  chromedriver_path = possible_paths.find { |path| path.present? && File.exist?(path) }
  
  # If still not found, try to use system chromedriver (may fail later, but at least we tried)
  unless chromedriver_path
    chromedriver_path = ENV.fetch('CHROMEDRIVER_PATH', nil)
    chromedriver_path ||= begin
      # Try common locations one more time
      ['chromedriver', '/usr/local/bin/chromedriver', '/usr/bin/chromedriver'].find do |path|
        system("command -v #{path} > /dev/null 2>&1") || File.exist?(path)
      end || '/usr/bin/chromedriver'  # Final fallback
    end
  end
  
  service = Selenium::WebDriver::Service.chrome(
    path: chromedriver_path
  )

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options, service: service)
end
