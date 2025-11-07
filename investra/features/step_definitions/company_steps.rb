# features/step_definitions/company_steps.rb
# Basic step definitions using Capybara for the Company Management feature.
# You may adapt selectors/paths to match your actual Rails routes and forms.

Given("I am logged in as an admin") do
  @admin = User.create!(email: "admin@example.com", password: "password", role: "admin")
  visit new_user_session_path
  fill_in "Email", with: @admin.email
  fill_in "Password", with: "password"
  click_button "Log in"
end

Given("I am logged in as a non-admin user") do
  @user = User.create!(email: "user@example.com", password: "password", role: "trader")
  visit new_user_session_path
  fill_in "Email", with: @user.email
  fill_in "Password", with: "password"
  click_button "Log in"
end

Given("I am on the new company page") do
  visit new_company_path
end

Given("an existing company with ticker {string}") do |ticker|
  Company.create!(name: "Existing Co", ticker: ticker, sector: "General")
end

When('I fill in {string} with {string}') do |field, value|
  fill_in field, with: value
end

When('I press {string}') do |button|
  click_button button
end

When("I visit the companies management page") do
  visit companies_path
end

# Removed duplicate step - now in common_steps.rb