# Background steps
Given('the following roles exist:') do |table|
  table.hashes.each do |row|
    Role.find_or_create_by!(name: row['name']) do |role|
      role.description = row['description']
    end
  end
end

Given('the following companies exist:') do |table|
  table.hashes.each do |company|
    Company.create!(
      name: company['name'],
      domain: company['domain']
    )
  end
end

Given('I am on the registration page') do
  visit signup_path
end

When('I fill in {string} with {string}') do |field, value|
  @last_email = value if field == 'Email'
  @last_password = value if field == 'Password'
  fill_in field, with: value
end

When('I press {string}') do |button|
    click_button button
end

Then('I should be on the trader dashboard page') do
  expect(current_path).to eq(trader_dashboard_path)  # /dashboard/trader
end

Then('I should be on the associate dashboard page') do
  expect(current_path).to eq(associate_dashboard_path)  # /dashboard/associate
end

Then('I should be on the manager dashboard page') do
  expect(current_path).to eq(manager_dashboard_path)  # /dashboard/manager
end

Then('I should be on the admin dashboard page') do
  expect(current_path).to eq(admin_dashboard_path)  # /dashboard/admin
end

Then('I should be on the registration page') do
  expect(current_path).to eq(signup_path)
end


Then('I should have the role {string}') do |role_name|
  user = User.find_by(email: @last_email || 'newuser@example.com')
  expect(user.roles.pluck(:name)).to include(role_name)
end


Then('I should not have any other roles assigned') do
  user = User.find_by(email: @last_email || 'trader@example.com')
  expect(user.roles.count).to eq(1)
end

Then('my password should be hashed in the database') do
  user = User.find_by(email: @last_email || 'newuser@example.com')
  expect(user.password_digest).not_to be_nil
  expect(user.password_digest).to match(/^\$2a\$/)
  expect(user.password_digest).not_to eq('SecurePass123')
  expect(user.password_digest).not_to eq(@last_password) if @last_password
end

Then('the plain text password {string} should not be stored') do |password|
  user = User.find_by(email: @last_email || 'secure@example.com')
  expect(user.password_digest).not_to eq(password)
  expect(user.password_digest).not_to include(password)
  expect(user.attributes).not_to have_key('password')
end


Given('a user exists with email {string}') do |email|
  trader_role = Role.find_by(name: 'Trader')
  
  user = User.new(
    email: email,
    password: 'SecurePass123',
    password_confirmation: 'SecurePass123',
    first_name: 'Existing',
    last_name: 'User'
  )
  
  user.roles << trader_role if trader_role
  user.save!
end

Then('both users should exist in the system') do
  first_user = User.find_by(email: 'first@example.com')
  second_user = User.find_by(email: 'second@example.com')
  expect(first_user).not_to be_nil
  expect(second_user).not_to be_nil
  expect(User.count).to be >= 2
end

Then('I should be affiliated with company {string}') do |company_name|
  user = User.find_by(email: @last_email)
  company = Company.find_by(name: company_name)
  expect(user.company_id).to eq(company.id)
  expect(user.company).to eq(company)
end

Then('a new company {string} should be created with domain {string}') do |company_name, domain|
  company = Company.find_by(name: company_name)
  expect(company).not_to be_nil
  expect(company.name).to eq(company_name)
  expect(company.domain).to eq(domain)
end

After do
  @last_email = nil
  @last_password = nil
end


