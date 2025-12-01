# Common step definitions used across multiple features

# Generic click button/link step
When("I click {string}") do |button_text|
  click_button button_text
rescue Capybara::ElementNotFound
  click_link button_text
end

# Generic expectation step
Then("I should see {string}") do |message|
  expect(page).to have_content(message)
end

# Generic page navigation step
Given("I am on the {string} page") do |page_name|
  case page_name
  when "Stocks"
    visit stocks_path
  when "Portfolio"
    visit portfolio_path
  when "User Management"
    visit user_management_path
  when "Manage Team"
    visit manage_team_path
  else
    raise "Unknown page: #{page_name}"
  end
end

When('I fill in {string} with {string}') do |field, value|
  fill_in field, with: value
end

When("I press {string}") do |button|
  click_button button
end

