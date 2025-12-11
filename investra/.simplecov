# Unified SimpleCov configuration for both RSpec and Cucumber
require 'simplecov'

SimpleCov.start 'rails' do
  add_filter '/bin/'
  add_filter '/db/'
  add_filter '/spec/'
  add_filter '/test/'
  add_filter '/features/'
  add_filter '/config/'
  add_filter '/vendor/'
  
  # Filter external API client integrations (third-party wrappers)
  add_filter '/app/services/market_data/yahoo_client.rb'
  add_filter '/app/services/market_data/massive_client.rb'
  
  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Helpers', 'app/helpers'
  add_group 'Mailers', 'app/mailers'
  add_group 'Services', 'app/services'
  add_group 'Views', 'app/views'
  
  # Merge results from multiple test suites
  use_merging true
  merge_timeout 3600  # 1 hour
end

