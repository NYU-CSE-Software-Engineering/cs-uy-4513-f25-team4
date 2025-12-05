# Common step definitions used across multiple features

# Generic click button/link step
When("I click {string}") do |text|
  # First try to click a button
  if page.has_button?(text, wait: 0)
    click_button(text)
  # Then try to click a link
  elsif page.has_link?(text, wait: 0)
    click_link(text)
  elsif page.has_css?('label', text: text, exact_text: true, wait: 0)
    find('label', text: text, exact_text: true).click
  else
    raise "Could not find button, link, or label with text '#{text}'"
  end
end

# Generic form fill/submit steps
When('I fill in {string} with {string}') do |field, value|
  @last_email = value if field == "Email"
  @last_password = value if field == "Password"
  @current_email = value if field == "Email"
  fill_in field, with: value
end

When('I press {string}') do |button|
  click_button button
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
  when "Watchlist"
    visit watchlist_path
  when "Credit Line"
    visit credit_line_path
  when "User Management"
    visit user_management_path
  when "Manage Team"
    visit manage_team_path
  else
    raise "Unknown page: #{page_name}"
  end
end
