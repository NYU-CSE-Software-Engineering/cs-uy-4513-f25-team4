# Custom Rake task to run all tests and generate correct combined coverage
namespace :coverage do
  desc 'Run all tests (RSpec + Cucumber) and generate combined coverage report'
  task :all do
    require 'simplecov'
    
    # Clear old coverage
    FileUtils.rm_rf('coverage')
    
    # Run RSpec
    puts "=== Running RSpec ==="
    system('RAILS_ENV=test bundle exec rspec')
    
    # Run Cucumber
    puts "=== Running Cucumber ==="
    system('RAILS_ENV=test bundle exec cucumber')
    
    # Fix .last_run.json to show merged coverage
    puts "=== Updating .last_run.json ==="
    if File.exist?('coverage/index.html')
      html = File.read('coverage/index.html')
      if match = html.match(/(\d+\.\d+)%/)
        coverage_percent = match[1].to_f
        File.write('coverage/.last_run.json', JSON.pretty_generate({
          result: { line: coverage_percent }
        }))
        puts "✅ Coverage: #{coverage_percent}%"
      end
    end
  end
end

