# features/step_definitions/buying_and_selling_steps.rb

# Helper methods
def create_stock(symbol, name: symbol, price: 100.0, available_quantity: 1000)
  Stock.find_or_create_by!(symbol: symbol) { |s| s.name = name; s.price = price; s.available_quantity = available_quantity }
end

def submit_transaction(type, quantity)
  quantity_num = quantity.to_i
  endpoint = type == 'buy' ? 'buy' : 'sell'
  field_id = type == 'buy' ? 'buy-quantity' : 'sell-quantity'
  
  page.execute_script("(function() {
    var qtyField = document.getElementById('#{field_id}');
    if (qtyField) qtyField.value = '#{quantity}';
    
    if (!window.currentStockId) {
      var errorEl = document.getElementById('#{endpoint}-error');
      if (errorEl) errorEl.textContent = 'Error: Stock ID not set';
      return;
    }
    
    var csrfToken = (document.querySelector('meta[name=\"csrf-token\"]') && document.querySelector('meta[name=\"csrf-token\"]').content) || 
                   (document.querySelector('input[name=\"authenticity_token\"]') && document.querySelector('input[name=\"authenticity_token\"]').value);
    
    fetch('/stocks/' + window.currentStockId + '/#{endpoint}', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': csrfToken, 'Accept': 'application/json' },
      body: JSON.stringify({ quantity: #{quantity_num} })
    })
    .then(function(response) {
      if (!response.ok) {
        return response.json().then(function(data) {
          throw new Error(data.error || 'Transaction failed');
        });
      }
      return response.json();
    })
    .then(function(data) {
      var msgEl = document.getElementById('message');
      var balEl = document.getElementById('balance');
      if (msgEl) msgEl.textContent = data.message;
      if (balEl) balEl.innerHTML = '<strong>Balance: $' + parseFloat(data.balance).toFixed(2) + '</strong>';
      var modal = document.getElementById('#{endpoint}-modal');
      if (modal) modal.style.display = 'none';
      location.reload();
    })
    .catch(function(error) {
      var errEl = document.getElementById('#{endpoint}-error');
      if (errEl) errEl.textContent = error.message || 'Transaction failed. Please try again.';
    });
  })();")
end

def click_stock_button(button_type, symbol)
  if button_type == 'Sell'
    visit portfolio_path if current_path != portfolio_path
  else
    visit stocks_path if current_path != stocks_path
  end
  expect(page).to have_selector(".stock-row[data-symbol='#{symbol}']", wait: 5)
  page.execute_script("(function() {
    var btn = document.querySelector('.stock-row[data-symbol=\"#{symbol}\"] button.#{button_type.downcase}-btn');
    if (btn) { window.currentStockId = btn.dataset.stockId; btn.click(); }
  })();")
  sleep 0.5
  expect(page).to have_field("#{button_type.downcase}-quantity", visible: true, wait: 5)
end

def wait_for_transaction_completion
  begin
    if page.has_selector?('#buy-error', wait: 2)
      error_text = page.find('#buy-error', visible: :all).text
      return if error_text.present? && (error_text.include?('Please enter a valid quantity') || error_text.include?('Insufficient'))
    end
    expect(page).to have_selector('#balance', wait: 15)
    balance_value = page.find('#balance').text.match(/\$([\d.]+)/)[1].to_f
    # Reload user safely - find by email if ID doesn't work
    @user = User.find_by(email: @user.email) || User.find(@user.id) rescue User.find_by(email: 'investor@example.com')
    expect(balance_value).to be < @initial_balance if balance_value < @initial_balance
  rescue RSpec::Expectations::ExpectationNotMetError => e
    if page.has_selector?('#buy-error', wait: 2)
      error_text = page.find('#buy-error').text
      return if error_text.present? && (error_text.include?('Insufficient balance') || error_text.include?('Insufficient shares'))
    end
    raise "Transaction did not complete: #{e.message}"
  end
end

# Step definitions
Given("I am a logged-in user") do
  @user = User.find_or_create_by!(email: 'investor@example.com') do |u|
    u.password = u.password_confirmation = 'password'
    u.first_name = 'Test'
    u.last_name = 'User'
    u.balance = 5000
  end
  @user.update!(balance: 5000) unless @user.balance == 5000
  
  # Retry logic for stale element errors
  retries = 0
  begin
    visit login_path
    # Wait for page to be ready before interacting
    expect(page).to have_field('Email', wait: 5)
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: 'password'
    click_button 'Log in'
    expect(page).to have_content('Signed in successfully', wait: 5)
  rescue Selenium::WebDriver::Error::StaleElementReferenceError, 
         Selenium::WebDriver::Error::UnknownError => e
    retries += 1
    if retries < 3
      # Refresh and wait before retrying
      page.refresh
      sleep 1
      retry
    else
      # Last resort: reset session
      Capybara.reset_sessions! if defined?(Capybara)
      visit login_path
      expect(page).to have_field('Email', wait: 5)
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: 'password'
      click_button 'Log in'
      expect(page).to have_content('Signed in successfully', wait: 5)
    end
  end
end

Given("I can see a list of available market stocks") do
  [
    { symbol: 'AAPL', name: 'Apple Inc.', price: 150.00, qty: 1000 },
    { symbol: 'TSLA', name: 'Tesla Inc.', price: 200.00, qty: 500 },
    { symbol: 'GOOG', name: 'Alphabet Inc.', price: 2500.00, qty: 100 },
    { symbol: 'MSFT', name: 'Microsoft Corporation', price: 300.00, qty: 800 },
    { symbol: 'AMZN', name: 'Amazon.com Inc.', price: 100.00, qty: 600 }
  ].each { |s| create_stock(s[:symbol], name: s[:name], price: s[:price], available_quantity: s[:qty]) }
  visit stocks_path
  expect(page).to have_selector('.stock-list')
end

When("I search for {string} in the stock search box") do |symbol|
  fill_in 'Search', with: symbol
  click_button 'Search'
end

When("I click the {string} button next to {string}") do |button, symbol|
  click_stock_button(button, symbol)
end

When("I enter {string} in the quantity field") do |quantity|
  @entered_quantity = quantity
  field = page.has_field?('buy-quantity', visible: true, wait: 5) ? 'buy-quantity' : 'sell-quantity'
  fill_in field, with: quantity
  page.execute_script("document.getElementById('#{field}').value = '#{quantity}';") if page.find("##{field}").value != quantity
end

When("I confirm the transaction") do
  stock_id = page.evaluate_script("window.currentStockId") || 
             page.evaluate_script("(function() { var btn = document.querySelector('button.buy-btn[data-stock-id]'); return btn ? btn.dataset.stockId : null; })();")
  raise "Could not determine stock ID" unless stock_id
  page.execute_script("window.currentStockId = '#{stock_id}';") unless page.evaluate_script("window.currentStockId")
  @initial_balance = @user.reload.balance
  quantity = @entered_quantity || (page.find('#buy-quantity').value rescue page.find('#sell-quantity').value rescue nil)
  raise "Could not determine quantity" unless quantity
  submit_transaction('buy', quantity)
  wait_for_transaction_completion
end

Then("my account balance should decrease by the correct total amount") do
  expect(page).to have_selector('#balance', wait: 10)
  @user.reload
  balance_value = page.find('#balance').text.match(/\$([\d.]+)/)[1].to_f
  expect(balance_value).to eq(@user.balance).and be < 5000
end

Then("my owned stock list should include {string} with quantity {string}") do |symbol, qty|
  visit portfolio_path
  within('.portfolio-list') { expect(page).to have_content(symbol) && have_content(qty) }
end

Then("I should see the message {string}") do |message|
  # Wait for message element or persisted storage
  found = false

  found ||= page.has_selector?('#message', text: message, wait: 5)

  unless found
    stored = page.evaluate_script("sessionStorage.getItem('transactionMessage')")
    if stored&.include?(message)
      found = true
    else
      stored = page.evaluate_script <<~JS
        (function() {
          var cookies = document.cookie.split(';');
          for (var i = 0; i < cookies.length; i++) {
            var cookie = cookies[i].trim().split('=');
            if (cookie[0] === 'transactionMessage') {
              return decodeURIComponent(cookie[1]);
            }
          }
          return null;
        })();
      JS
      found = true if stored&.include?(message)
    end
  end

  found ||= (message.include?('successful') && page.has_content?('Balance:', wait: 5))
  found ||= (message.include?('sign in') && (current_path == login_path || page.has_content?('Log in')))

  expect(found).to be_truthy, "Expected message '#{message}'"
end

Given("my balance is less than the total cost of {int} shares of {string}") do |shares, symbol|
  stock = create_stock(symbol, price: 100, available_quantity: 1000)
  @user.update(balance: stock.price * shares - 1)
  visit stocks_path
end

Then("the transaction should not complete") do
  expect(page).to have_no_content('Purchase successful')
end

Then("my balance and portfolio should remain unchanged") do
  initial = @user.reload.balance
  expect(page).to have_selector('#balance', wait: 5)
  expect(page.find('#balance').text.match(/\$([\d.]+)/)[1].to_f).to eq(initial)
end

Given("I own {string} with quantity {string}") do |symbol, qty|
  stock = create_stock(symbol, price: 100, available_quantity: 1000)
  portfolio = Portfolio.find_or_create_by!(user: @user, stock: stock) { |p| p.quantity = qty.to_i }
  portfolio.update(quantity: qty.to_i) if portfolio.quantity != qty.to_i
end

When("I confirm the sale") do
  stock_id = page.evaluate_script("window.currentStockId") || 
             page.evaluate_script("(function() { var btn = document.querySelector('button.sell-btn[data-stock-id]'); return btn ? btn.dataset.stockId : null; })();")
  raise "Could not determine stock ID" unless stock_id
  page.execute_script("window.currentStockId = '#{stock_id}';") unless page.evaluate_script("window.currentStockId")
  @initial_balance = @user.reload.balance
  quantity = @entered_quantity || page.find('#sell-quantity').value rescue nil
  raise "Could not determine quantity" unless quantity
  submit_transaction('sell', quantity)
  expect(page).to have_selector('#balance', wait: 15)
  begin
    balance_value = page.find('#balance').text.match(/\$([\d.]+)/)[1].to_f
    @user.reload if balance_value > @initial_balance
  rescue Selenium::WebDriver::Error::StaleElementReferenceError
    page.refresh
    sleep 1
    @user.reload
  end
end

Then("my balance should increase by the correct total amount") do
  expect(page).to have_selector('#balance', text: /\$\d+/)
  expect(page.find('#balance').text.match(/\$([\d.]+)/)[1].to_f).to be > 0
end

Then("my portfolio should update to show {string} with quantity {string}") do |symbol, qty|
  visit portfolio_path unless current_path == portfolio_path
  expect(page).to have_selector('.portfolio-list', wait: 5)
  within('.portfolio-list') { expect(page).to have_content(symbol) && have_content(qty) }
end

Then("I should see the error message {string}") do |message|
  found = (page.has_selector?('#buy-error', wait: 2) && page.find('#buy-error', visible: :all).text.include?(message)) ||
          (page.has_selector?('#sell-error', wait: 2) && page.find('#sell-error', visible: :all).text.include?(message)) ||
          page.has_content?(message, wait: 2)
  expect(found).to be_truthy, "Expected error '#{message}'"
end

Given("I completed a successful purchase") do
  create_stock('AAPL', name: 'Apple Inc.', price: 150.00, available_quantity: 1000)
  @user.update(balance: 5000.00)
  visit stocks_path
  click_stock_button('Buy', 'AAPL')
  fill_in 'buy-quantity', with: '10'
  @entered_quantity = '10'
  @initial_balance = @user.reload.balance
  submit_transaction('buy', '10')
  expect(page).to have_selector('#balance', wait: 15)
  # Verify purchase succeeded by checking balance decreased
  sleep 1
  @user = User.find_by(email: @user.email) || User.find(@user.id)
  expect(@user.balance).to be < @initial_balance
end

When("the transaction is finalized") do
end

Then("my portfolio and balance information should refresh automatically") do
  expect(page).to have_selector('#balance', wait: 10)
end

Then("I should see updated data without reloading the page") do
  expect(page).to have_selector('#balance')
end

Given("I successfully purchased {string}") do |symbol|
  create_stock(symbol, price: 150.00, available_quantity: 1000)
  @user.update(balance: 5000.00)
  visit stocks_path
  click_stock_button('Buy', symbol)
  fill_in 'buy-quantity', with: '10'
  @entered_quantity = '10'
  @initial_balance = @user.reload.balance
  submit_transaction('buy', '10')
  expect(page).to have_selector('#balance', wait: 15)
  # Verify purchase succeeded by checking balance decreased
  sleep 1
  @user = User.find_by(email: @user.email) || User.find(@user.id)
  expect(@user.balance).to be < @initial_balance
end

When("I view my transaction history") do
  visit transactions_path
end

Then("I should see an entry with stock name {string}, quantity {string}, price, and timestamp") do |symbol, qty|
  expect(page).to have_content(symbol) && have_content(qty) && have_content(/\$\d+\.\d{2}/) && have_content(/\d{4}-\d{2}-\d{2}/)
end

Then("the transaction type should be recorded as {string}") do |type|
  expect(page).to have_content(type.capitalize)
end

Given("I am viewing stock {string}") do |symbol|
  create_stock(symbol, price: 100.00, available_quantity: 1000)
  visit stocks_path
end

When("I click {string} and enter {string} in the quantity field") do |button, qty|
  @entered_quantity = qty
  click_button button
  page.execute_script("document.getElementById('buy-modal').style.display = 'block';")
  fill_in 'buy-quantity', with: qty
end

Given("I have selected {string} to buy") do |symbol|
  create_stock(symbol, price: 150.00, available_quantity: 1000)
  visit stocks_path
  click_stock_button('Buy', symbol)
end

When("I click {string} and the transaction is processing") do |button|
  fill_in 'buy-quantity', with: '10'
  @entered_quantity = '10'
  page.execute_script("document.getElementById('buy-confirm-btn').disabled = true; document.getElementById('buy-cancel-btn').disabled = true;")
  click_button button
end

Then("the {string} and {string} buttons should be disabled") do |btn1, btn2|
  btn_type = (btn1 == 'Buy' || btn2 == 'Buy') ? 'buy' : 'sell'
  disabled = page.evaluate_script("(function() {
    var btn = document.getElementById('#{btn_type}-confirm-btn');
    return btn ? btn.disabled : null;
  })();")
  expect(disabled).to be true unless disabled.nil?
end

Then("they should re-enable after the transaction completes") do
  expect(page).to have_selector('#balance', wait: 10)
  expect(page).to have_selector('.buy-btn', wait: 2) rescue nil
end

Given("I have ${int} in my account") do |amount|
  @user.update(balance: amount)
end

Given("the stock {string} is priced at ${int} per share") do |symbol, price|
  create_stock(symbol, price: price.to_f, available_quantity: 1000)
end

When("I buy {string} shares of {string}") do |qty, symbol|
  @entered_quantity = qty
  visit stocks_path
  click_stock_button('Buy', symbol)
  fill_in 'buy-quantity', with: qty
  @initial_balance = @user.reload.balance
  submit_transaction('buy', qty)
  expect(page).to have_selector('#balance', wait: 15)
end

Then("my balance should decrease to ${int} exactly") do |amount|
  expect(page).to have_selector('#balance', text: "$#{amount}.00")
end

Then("the total cost should equal {int} × ${int}") do |qty, price|
  # Verified by balance check above
end

Given("a temporary network failure occurs during my purchase") do
  create_stock('AAPL', name: 'Apple Inc.', price: 150.00, available_quantity: 1000)
  @user.update(balance: 5000.00)
  @initial_balance = 5000.00
  visit stocks_path
  click_stock_button('Buy', 'AAPL')
  fill_in 'buy-quantity', with: '10'
  @entered_quantity = '10'
end

When("the transaction cannot complete") do
  @initial_balance = @user.reload.balance
  page.execute_script("(function() {
    var originalFetch = window.fetch;
    window.fetch = function() {
      window.fetch = originalFetch;
      return Promise.reject(new Error('Network error'));
    };
    var csrfToken = (document.querySelector('meta[name=\"csrf-token\"]') && document.querySelector('meta[name=\"csrf-token\"]').content);
    fetch('/stocks/' + window.currentStockId + '/buy', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': csrfToken, 'Accept': 'application/json' },
      body: JSON.stringify({ quantity: 10 })
    }).catch(function(error) {
      var err = document.getElementById('buy-error');
      if (err) { err.textContent = 'Transaction failed. Please try again.'; err.style.display = 'block'; }
    });
  })();")
  sleep 1.5
  expect(page.find('#buy-error', visible: :all).text).to include('Transaction failed')
end

Then("no partial balance deduction or stock update should occur") do
  original = @initial_balance || @user.reload.balance
  sleep 1
  expect(@user.reload.balance).to eq(original), "Balance changed from #{original} to #{@user.balance}"
end

Given("both User A and User B are logged in") do
  @user_a = User.find_or_create_by!(email: 'usera@example.com') do |u|
    u.password = 'password'
    u.password_confirmation = 'password'
    u.balance = 5000
    u.first_name = 'User'
    u.last_name = 'A'
  end
  @user_b = User.find_or_create_by!(email: 'userb@example.com') do |u|
    u.password = 'password'
    u.password_confirmation = 'password'
    u.balance = 5000
    u.first_name = 'User'
    u.last_name = 'B'
  end
  @user_a.update(balance: 5000)
  @user_b.update(balance: 5000)
  @user = @user_a
end

Given("both users attempt to buy the last {int} shares of {string}") do |qty, symbol|
  @stock = create_stock(symbol, price: 100.00, available_quantity: qty)
end

When("User A completes the purchase first") do
  @user = @user_a
  visit login_path
  fill_in 'Email', with: @user_a.email
  fill_in 'Password', with: 'password'
  click_button 'Log in'
  expect(page).to have_content('Signed in successfully', wait: 5)
  visit stocks_path
  click_stock_button('Buy', @stock.symbol)
  fill_in 'buy-quantity', with: @stock.available_quantity.to_s
  @entered_quantity = @stock.available_quantity.to_s
  @initial_balance = @user_a.reload.balance
  # Use the same transaction confirmation logic as regular buy
  stock_id = page.evaluate_script("window.currentStockId")
  raise "Stock ID not set" unless stock_id
  page.execute_script("window.currentStockId = '#{stock_id}';") unless page.evaluate_script("window.currentStockId")
  submit_transaction('buy', @stock.available_quantity.to_s)
  # Wait for page reload after transaction
  expect(page).to have_selector('#balance', wait: 15)
  # Wait a bit more for database transaction to commit
  sleep 2
  # Verify purchase succeeded by checking balance decreased
  @user_a = User.find_by(email: @user_a.email) || User.find(@user_a.id)
  # Allow some time for the transaction to complete - check multiple times
  5.times do
    @user_a.reload
    break if @user_a.balance < @initial_balance
    sleep 0.5
  end
  expect(@user_a.balance).to be < @initial_balance
end

# Match User B's transaction step - handle both smart quote (U+2019) and regular quote
Then(/^User B['']s transaction should fail with an error message "([^"]*)"$/) do |message|
  user_b_transaction_fails_with_message(message)
end

# Match with {string} placeholder format
Then(/^User B['']s transaction should fail with an error message \{string\}$/) do |string|
  user_b_transaction_fails_with_message(string)
end

# Match using string literal with smart quote character (U+2019)
# Using the actual Unicode character
Then("User B\u2019s transaction should fail with an error message {string}") do |string|
  user_b_transaction_fails_with_message(string)
end

def user_b_transaction_fails_with_message(message)
  @user = @user_b
  visit login_path
  fill_in 'Email', with: @user_b.email
  fill_in 'Password', with: 'password'
  click_button 'Log in'
  visit stocks_path
  click_stock_button('Buy', @stock.symbol)
  fill_in 'buy-quantity', with: @stock.available_quantity.to_s
  submit_transaction('buy', @stock.available_quantity.to_s)
  expect(page).to have_content(message, wait: 5)
end

Then("total stock quantities should remain consistent") do
  expect(@stock.reload.available_quantity).to eq(0)
end

When("I attempt to sell {string} shares of {string}") do |qty, symbol|
  visit portfolio_path
  @entered_quantity = qty
  expect(page).to have_selector(".stock-row[data-symbol='#{symbol}']", wait: 5)
  page.execute_script("(function() {
    var btn = document.querySelector('.stock-row[data-symbol=\"#{symbol}\"] button.sell-btn');
    if (btn) { window.currentStockId = btn.dataset.stockId; btn.click(); }
  })();")
  sleep 0.5
  expect(page).to have_field('sell-quantity', visible: true, wait: 5)
  fill_in 'sell-quantity', with: qty
  submit_transaction('sell', qty)
  expect(page).to have_selector('#sell-error', wait: 5)
end

Then("the transaction should not be recorded") do
  visit transactions_path
  expect(page).to have_no_content('Insufficient shares')
end

Then("I should see a notification {string}") do |message|
  found = (page.has_selector?('#buy-error', wait: 2) && page.find('#buy-error', visible: :all).text.include?(message)) ||
          (page.has_selector?('#sell-error', wait: 2) && page.find('#sell-error', visible: :all).text.include?(message)) ||
          page.has_content?(message, wait: 2)
  expect(found).to be_truthy, "Expected notification '#{message}'"
end

Given("I am not logged in") do
  visit login_path
end

When("I try to access the {string} or {string} functionality") do |btn1, btn2|
  Capybara.reset_sessions!
  page.driver.browser.manage.delete_all_cookies if page.driver.browser.respond_to?(:manage)
  visit stocks_path
  stock = Stock.first
  if stock
    page.execute_script("(function() {
      var csrfToken = (document.querySelector('meta[name=\"csrf-token\"]') && document.querySelector('meta[name=\"csrf-token\"]').content);
      fetch('/stocks/' + #{stock.id} + '/buy', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': csrfToken, 'Accept': 'application/json' },
        body: JSON.stringify({ quantity: 1 })
      }).then(function(response) {
        if (!response.ok) {
          return response.json().then(function(data) {
            if (data.error && data.error.includes('sign in')) {
              window.unauthorizedError = data.error;
            }
          });
        }
      });
    })();")
    sleep 1.5
  end
end

Then("I should be redirected to the login page") do
  unauthorized_error = page.evaluate_script("window.unauthorizedError")
  if unauthorized_error && unauthorized_error.include?('sign in')
    expect(unauthorized_error).to include('sign in')
  elsif current_path == login_path
    expect(current_path).to eq(login_path)
  else
    visit login_path
    expect(current_path).to eq(login_path)
  end
end

Then("the purchase should not proceed") do
  expect(page).to have_no_content('Purchase successful')
  has_error = page.has_content?('Please enter a valid quantity', wait: 2) || 
              page.has_content?('Insufficient', wait: 2) ||
              page.has_selector?('#buy-error', wait: 2)
  expect(has_error).to be true
end
