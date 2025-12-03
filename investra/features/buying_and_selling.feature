@javascript
Feature: Buying and Selling Stocks
  As a registered investor
  I want to buy and sell stocks through the platform
  So that I can manage my investment portfolio effectively and keep my balance updated in real time

  Background:
    Given I am a logged-in user
    And I am on the "Stocks" page

  # Successful stock purchase
  Scenario: User successfully buys a stock
    Given I can see a list of available market stocks
    When I search for "AAPL" in the stock search box
    And I click the "Buy" button next to "AAPL"
    And I enter "10" in the quantity field
    And I confirm the transaction
    Then my account balance should decrease by the correct total amount
    And my owned stock list should include "AAPL" with quantity "10"
    And I should see the message "Purchase successful."

  # Insufficient balance during purchase
  Scenario: User fails to buy due to insufficient balance
    Given my balance is less than the total cost of 50 shares of "TSLA"
    When I search for "TSLA" in the stock search box
    And I click the "Buy" button next to "TSLA"
    And I enter "50" in the quantity field
    And I confirm the transaction
    Then the transaction should not complete
    And I should see the error message "Insufficient balance"
    And my balance and portfolio should remain unchanged

  # Successful stock sale
  Scenario: User successfully sells owned stock
    Given I own "AAPL" with quantity "10"
    When I click the "Sell" button next to "AAPL"
    And I enter "5" in the quantity field
    And I confirm the sale
    Then my balance should increase by the correct total amount
    And my portfolio should update to show "AAPL" with quantity "5"
    And I should see the message "Sale successful."

  # Attempt to sell more shares than owned
  Scenario: User fails to sell more shares than owned
    Given I own "AAPL" with quantity "5"
    When I attempt to sell "10" shares of "AAPL"
    Then I should see the error message "Insufficient shares"
    And the transaction should not be recorded

  # Portfolio and balance auto-refresh after transaction
  Scenario: System refreshes data after transaction
    Given I completed a successful purchase
    When the transaction is finalized
    Then my portfolio and balance information should refresh automatically
    And I should see updated data without reloading the page

  # Concurrency handling between multiple users
  Scenario: Two users attempt to buy the same stock simultaneously
    Given both User A and User B are logged in
    And both users attempt to buy the last 10 shares of "GOOG"
    When User A completes the purchase first
    Then User B’s transaction should fail with an error message "Stock no longer available"
    And total stock quantities should remain consistent

  # Transaction history logging
  Scenario: Transaction details are recorded after completion
    Given I successfully purchased "AAPL"
    When I view my transaction history
    Then I should see an entry with stock name "AAPL", quantity "10", price, and timestamp
    And the transaction type should be recorded as "buy"

  # Invalid input when buying
  Scenario: User enters invalid quantity for purchase
    Given I am viewing stock "MSFT"
    When I click "Buy" and enter "abc" in the quantity field
    And I confirm the transaction
    Then I should see the error message "Please enter a valid quantity"
    And the purchase should not proceed

  # UI button state during transaction
  Scenario: Buttons are disabled during active transaction
    Given I have selected "AAPL" to buy
    When I click "Buy" and the transaction is processing
    Then the "Buy" and "Sell" buttons should be disabled
    And they should re-enable after the transaction completes

  # Balance and price calculation accuracy
  Scenario: Balance and cost are calculated precisely
    Given I have $5000 in my account
    And the stock "AMZN" is priced at $100 per share
    When I buy "10" shares of "AMZN"
    Then my balance should decrease to $4000 exactly
    And the total cost should equal 10 × $100

  # Error recovery from failed transaction
  Scenario: System recovers cleanly after failed transaction
    Given a temporary network failure occurs during my purchase
    When the transaction cannot complete
    Then I should see a notification "Transaction failed. Please try again."
    And no partial balance deduction or stock update should occur

  # Security and authorization check
  Scenario: Unauthorized user attempts to trade
    Given I am not logged in
    When I try to access the "Buy" or "Sell" functionality
    Then I should be redirected to the login page
    And I should see the message "Please sign in to continue."
