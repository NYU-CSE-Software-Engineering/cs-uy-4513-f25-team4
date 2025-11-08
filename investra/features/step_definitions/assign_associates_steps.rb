Given("I am logged in as a Portfolio Manager") do
  @current_user = User.create!(
    email: 'manager@test.com', 
    role: 'Portfolio Manager',
    first_name: 'Test',
    last_name: 'Manager',
    password: 'password',
    password_confirmation: 'password'
  )
  visit new_user_session_path
  fill_in 'Email', with: @current_user.email
  fill_in 'Password', with: 'password'
  click_button 'Log in'
end

Given("my company is {string}") do |company_name|
  company = Company.find_or_create_by!(name: company_name)
  @current_user.update!(company: company)
end

Given('I am on the "Manage Team" page') do
  visit manage_team_path
end

Given("the following users exist:") do |table|
  table.hashes.each do |row|
    attrs = {
      email: row['Email'],
      role: row['Role'],
      first_name: row['First Name'] || 'Test',
      last_name: row['Last Name'] || 'User',
      password: 'password',
      password_confirmation: 'password'
    }
    if row['Company'] && row['Company'] != 'None'
      company = Company.find_or_create_by!(name: row['Company'])
      attrs[:company] = company
    end
    User.create!(attrs)
  end
end

Given("an associate {string} exists in my team") do |email|
  User.create!(
    email: email,
    role: 'Associate Trader',
    first_name: 'Test',
    last_name: 'Associate',
    manager: @current_user,
    company: @current_user.company,
    password: 'password',
    password_confirmation: 'password'
  )
end

# Removed duplicate step - now in common_steps.rb

When("I select user {string} from the available traders list") do |email|
  @last_selected_email = email
  click_link email
end

When("I click {string} for associate {string}") do |action, email|
  @last_removed_email = email
  click_button action
end

When("I confirm the removal") do
  click_button 'Confirm'
end

When("I search for {string}") do |search_term|
  fill_in 'search', with: search_term
end

# Removed duplicate step - now in common_steps.rb

Then("{string} should appear in my associates list") do |email|
  expect(page).to have_content(email)
end

Then("{string} should not appear in my associates list") do |email|
  expect(page).not_to have_content(email)
end

# Removed duplicate step - already defined in assign_as_admin_steps.rb

Then("the user should be associated with company {string}") do |company_name|
  user = User.find_by(email: @last_selected_email) if @last_selected_email
  user ||= User.find_by(email: @last_removed_email) if @last_removed_email
  user ||= @last_user if @last_user
  # Reload user from database to get latest state
  user = User.find(user.id) if user
  company = Company.find_by(name: company_name)
  expect(user.company).to eq(company)
end

Then("the user should not be associated with any company") do 
  user = User.find_by(email: @last_removed_email)
  expect(user.company).to be_nil
end

Then("I should not see {string}") do |text|
  expect(page).not_to have_content(text)
end