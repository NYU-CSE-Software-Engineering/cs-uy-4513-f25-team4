Given("I am logged in as a System Administrator") do
  @current_user = User.create!(email: 'admin@test.com', role: 'System Administrator')
  visit new_user_session_path
  fill_in 'Email', with: @current_user.email
  fill_in 'Password', with: 'password'
  click_button 'Log in'
end

# Removed duplicate - using generic step from buying_and_selling_steps.rb

Given("a user {string} exists with the following details:") do |email, table|
  data = table.rows_hash
  @last_user = User.create!(
    email: email,
    role: data['Role'],
    first_name: data['First Name'],
    last_name: data['Last Name']
  )
end

Given("the user is associated with company {string}") do |company_name|
  @last_user.update!(company: company_name)
end

Given("a user {string} exists with role {string}") do |email, role|
  @last_user = User.create!(email: email, role: role)
end

Given("a company {string} exists") do |company_name|
  Company.create!(name: company_name)
end

Given("a Portfolio Manager {string} exists at company {string}") do |email, company_name|
  User.create!(email: email, role: 'Portfolio Manager', company: company_name)
end

Given("the user is managed by {string}") do |manager_email|
  @last_user.update!(manager: manager_email)
end

When("I click {string} for user {string}") do |action, email|
  @last_user = User.find_by(email: email)
  click_button action
end

When("I select {string} from the role dropdown") do |role_name|
  select role_name, from: 'role'
end

When("I select company {string}") do |company_name|
  select company_name, from: 'company'
end

When("I select manager {string}") do |manager_email|
  select manager_email, from: 'manager'
end

When("I click {string}") do |button_text|
  click_button button_text
end

Then("I should see {string}") do |message|
  expect(page).to have_content(message)
end

Then("the user {string} should have role {string}") do |email, role|
  user = User.find_by(email: email)
  expect(user.role).to eq(role)
end

Then("the user should be associated with company {string}") do |company_name|
  expect(@last_user.company).to eq(company_name)
end

Then("the user should be managed by {string}") do |manager_email|
  expect(@last_user.manager).to eq(manager_email)
end

