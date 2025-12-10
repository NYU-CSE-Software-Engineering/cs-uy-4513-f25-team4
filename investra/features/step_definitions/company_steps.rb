# features/step_definitions/company_steps.rb
# Basic step definitions using Capybara for the Company Management feature.
# You may adapt selectors/paths to match your actual Rails routes and forms.

Given("I am logged in as an admin") do
  @admin = User.find_or_create_by!(email: "admin@example.com") do |user|
    user.password = "password"
    user.role = "admin"
    user.first_name = "Admin"
    user.last_name = "User"
  end
  Capybara.reset_sessions! if defined?(Capybara)
  if Capybara.current_driver == :rack_test
    page.driver.post(login_path, { email: @admin.email, password: "password" })
    visit stocks_path
  else
    visit login_path
    expect(page).to have_field("Email", wait: 5)
    fill_in "Email", with: @admin.email, id: "Email"
    fill_in "Password", with: "password", id: "Password"
    click_button "Log in"
  end
end

Given("I am logged in as a non-admin user") do
  @user = User.find_or_create_by!(email: "user@example.com") do |user|
    user.password = "password"
    user.role = "trader"
    user.first_name = "Regular"
    user.last_name = "User"
  end
  Capybara.reset_sessions! if defined?(Capybara)
  if Capybara.current_driver == :rack_test
    page.driver.post(login_path, { email: @user.email, password: "password" })
    visit stocks_path
  else
    visit login_path
    expect(page).to have_field("Email", wait: 5)
    fill_in "Email", with: @user.email, id: "Email"
    fill_in "Password", with: "password", id: "Password"
    click_button "Log in"
  end
end

Given("I am on the new company page") do
  visit new_company_path
end

Given("an existing company with ticker {string}") do |ticker|
  Company.find_or_create_by!(ticker: ticker) do |company|
    company.name = "Existing Co"
    company.sector = "General"
  end
end

When("I visit the companies management page") do
  visit companies_path
end

# Removed duplicate step - now in common_steps.rb
