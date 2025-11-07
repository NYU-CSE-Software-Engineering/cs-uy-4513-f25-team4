Given("I am logged in as a Portfolio Manager") do
  @current_user = User.create!(email: 'manager@test.com', role: 'Portfolio Manager')
  visit new_user_session_path
  fill_in 'Email', with: @current_user.email
  fill_in 'Password', with: 'password'
  click_button 'Log in'
end

Given("my company is {string}") do |company_name|
  @current_user.update!(company: company_name)
end

Given('I am on the "Manage Team" page') do
  visit manage_team_path
end

Given("the following users exist:") do |table|
  table.hashes.each do |row|
    User.create!(
      email: row['Email'],
      role: row['Role'],
      first_name: row['First Name'],
      last_name: row['Last Name'],
      company: (row['Company'] if row['Company'] != 'None')
    )
  end
end

Given("an associate {string} exists in my team") do |email|
  User.create!(
    email: email,
    role: 'Associate Trader',
    manager: @current_user.email,
    company: @current_user.company
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
  user = User.find_by(email: @last_selected_email)
  expect(user.company).to eq(company_name)
end

Then("the user should not be associated with any company") do 
  user = User.find_by(email: @last_removed_email)
  expect(user.company).to be_nil
end

Then("I should not see {string}") do |text|
  expect(page).not_to have_content(text)
end