Given('a user exists with email {string} and password {string}') do |email, password|
  @test_user = User.create!(
    email: email,
    password: password,
    password_confirmation: password,
    first_name: 'Test',
    last_name: 'User',
    role: 'Trader'  # Default role
  )
  @test_password = password
end

#user creation with role
Given('a user exists with email {string} and password {string} and role {string}') do |email, password, role_name|
  @test_user = User.create!(
    email: email,
    password: password,
    password_confirmation: password,
    first_name: 'Test',
    last_name: 'User',
    role: role_name.strip
  )
  @test_password = password
end

#Navigation

Given('I am on the login page') do
  visit login_path
end

Given('I am on the trader dashboard page') do
  visit trader_dashboard_path
end

When('I navigate to the trader dashboard page') do
  visit trader_dashboard_path
end

Given('I am on the profile page') do
  visit profile_path
end

When('I navigate to the profile page') do
  visit profile_path
end


# Already logged in
Given('I am logged in as {string}') do |email|
  user = User.find_by(email: email)
  
  # Create user if can't find user
  unless user
    user = User.create!(
      email: email,
      password: 'SecurePass123',
      password_confirmation: 'SecurePass123',
      first_name: 'Test',
      last_name: 'User',
      role: 'Trader'
    )
  end
  
  visit login_path
  fill_in 'Email', with: email
  fill_in 'Password', with: 'SecurePass123'
  click_button 'Log In'
  
  @current_user = user
  @current_email = email
end

# form input 



#page verification

Then('I should be on the login page') do
  expect(current_path).to eq(login_path)
end

Then('I should be on the trader dashboard page') do
  expect(current_path).to eq(trader_dashboard_path)
end

Then('I should be on the associate dashboard page') do
  expect(current_path).to eq(associate_dashboard_path)
end

Then('I should be on the manager dashboard page') do
  expect(current_path).to eq(manager_dashboard_path)
end

Then('I should be on the admin dashboard page') do
  expect(current_path).to eq(admin_dashboard_path)
end

Then('I should be on the profile page') do
  expect(current_path).to eq(profile_path)
end

Then('I should be logged in as {string}') do |email|
  expect(page).to have_link('Log Out')
  user = User.find_by(email: email)
  expect(page).to have_content(user.first_name) if user
end

Then('I should be logged in') do
  expect(page).to have_link('Log Out')
end


Then('I should still be logged in as {string}') do |email|
  expect(page).to have_link('Log Out')
end

Then('a session should be created for {string}') do |email|
  user = User.find_by(email: email)
  expect(user).not_to be_nil
  
  visit trader_dashboard_path
  expect(current_path).to eq(trader_dashboard_path)
  expect(page).not_to have_content('Please log in')
end

Then('the user session should be destroyed') do
  visit trader_dashboard_path
  expect(current_path).to eq(login_path)
end

Then('I should not be logged in') do
  expect(current_path).to eq(login_path)
end

Then('I should not have an active session') do
  visit trader_dashboard_path
  expect(current_path).to eq(login_path)
end

Then('my session data should be cleared') do
  visit trader_dashboard_path
  expect(current_path).to eq(login_path)
  expect(page).to have_content('Log In')
end

Then('my session should remain active') do
  expect(page).to have_link('Log Out')
  expect(current_path).not_to eq(login_path)
end

Then('my session should no longer exist') do
  visit trader_dashboard_path
  expect(current_path).to eq(login_path)
end

Then('I cannot access any protected pages without logging in again') do
  protected_pages = [trader_dashboard_path, profile_path]
  
  protected_pages.each do |page_path|
    visit page_path
    expect(current_path).to eq(login_path)
  end
end

After do
  @test_user = nil
  @test_password = nil
  @current_user = nil
  @current_email = nil
end