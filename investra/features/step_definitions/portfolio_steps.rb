# Portfolio Management Step Definitions

Given('I have an existing portfolio with multiple stocks') do
  pending "Portfolio model and stock associations not yet implemented"
end

Given('I am on the "My Portfolio" page') do
  visit '/portfolio'
end

When('I click on "Simulate Sell Value"') do
  click_button 'Simulate Sell Value'
end

Then('I should see a breakdown of my portfolio\'s gross value') do
  expect(page).to have_content('Gross Portfolio Value')
end

Then('I should see taxes and transaction fees deducted') do
  expect(page).to have_content('Taxes')
  expect(page).to have_content('Transaction Fees')
end

Then('I should see the final estimated return after deductions') do
  expect(page).to have_content('Net Return')
end

Then('I should see the confirmation message') do |expected_message|
  expect(page).to have_content(expected_message)
end

Given('I have no stocks in my portfolio') do
  pending "Empty portfolio setup not yet implemented"
end

Given('market data for one or more stocks is missing') do
  pending "Market data stubbing not yet implemented"
end

Given('a backend calculation error occurs') do
  pending "Error simulation not yet implemented"
end

Then('I should see an error message') do |expected_message|
  expect(page).to have_content(expected_message)
end

Then('I should see an alert message') do |expected_message|
  expect(page).to have_content(expected_message)
end
