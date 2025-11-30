Given("I am logged in as a System Administrator") do
  @current_user = User.create!(email: 'admin@test.com', password: "password", first_name: "System", last_name: "Admin", role: 'System Administrator')
  visit login_path
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
    last_name: data['Last Name'],
    password: 'password',
    password_confirmation: 'password'
  )
end

Given("the user is associated with company {string}") do |company_name|
  company = Company.find_or_create_by!(name: company_name)
  @last_user.update!(company: company)
end

Given("a user {string} exists with role {string}") do |email, role|
  @last_user = User.create!(
    email: email, 
    role: role,
    first_name: 'Test',
    last_name: 'User',
    password: 'password',
    password_confirmation: 'password'
  )
end

Given("a company {string} exists") do |company_name|
  Company.create!(name: company_name)
end

Given("a Portfolio Manager {string} exists at company {string}") do |email, company_name|
  company = Company.find_or_create_by!(name: company_name)
  User.create!(
    email: email, 
    role: 'Portfolio Manager', 
    company: company,
    first_name: 'Test',
    last_name: 'Manager',
    password: 'password',
    password_confirmation: 'password'
  )
end

Given("the user is managed by {string}") do |manager_email|
  manager = User.find_by(email: manager_email)
  @last_user.update!(manager: manager) if manager
end

When("I click {string} for user {string}") do |action, email|
  @last_user = User.find_by(email: email)
  # Refresh the page to ensure the newly created user is visible
  visit user_management_path
  # Find the table row containing the user's email - use xpath for more reliable matching
  row = find(:xpath, "//tr[td[contains(text(), '#{email}')]]")
  within(row) do
    begin
      click_button action
    rescue Capybara::ElementNotFound
      click_link action
    end
  end
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

# Removed duplicate steps - now in common_steps.rb

Then("the user {string} should have role {string}") do |email, role|
  user = User.find_by(email: email)
  expect(user.roles.first&.name).to eq(role)
end

# Removed duplicate step - using the more flexible version from assign_associates_steps.rb

Then("the user should be managed by {string}") do |manager_email|
  # Reload user from database to get latest state
  @last_user.reload if @last_user
  manager = User.find_by(email: manager_email)
  expect(@last_user.manager).to eq(manager)
end

