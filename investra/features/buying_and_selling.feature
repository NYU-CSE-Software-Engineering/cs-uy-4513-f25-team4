Feature: Buying and Selling Stocks
  As a registered investor
  I want to buy and sell stocks through the platform
  So that I can manage my investment portfolio effectively and keep my balance updated in real time

  Background:
    Given I am a logged-in user
    And I am on the "Stocks" page

  @javascript
  Scenario: User successfully buys a stock
    Given I can see a list of available market stocks
    When I search for "AAPL" in the stock search box
    And I click the "Buy" button next to "AAPL"
    And I enter "10" in the quantity field
    And I confirm the transaction
    Then my account balance should decrease by the correct total amount
    And my owned stock list should include "AAPL" with quantity "10"
    And I should see the message "Purchase successful."

  @javascript
  Scenario: User fails to buy due to insufficient balance
    Given my balance is less than the total cost of 50 shares of "TSLA"
    When I search for "TSLA" in the stock search box
    And I click the "Buy" button next to "TSLA"
    And I enter "50" in the quantity field
    And I confirm the transaction
    Then the transaction should not complete
    And I should see the error message "Insufficient balance"
    And my balance and portfolio should remain unchanged

  @javascript
  Scenario: User successfully sells owned stock
    Given I own "AAPL" with quantity "10"
    When I click the "Sell" button next to "AAPL"
    And I enter "5" in the quantity field
    And I confirm the sale
    Then my balance should increase by the correct total amount
    And my portfolio should update to show "AAPL" with quantity "5"
    And I should see the message "Sale successful."

  @javascript
  Scenario: User fails to sell more shares than owned
    Given I own "AAPL" with quantity "5"
    When I attempt to sell "10" shares of "AAPL"
    Then I should see the error message "Insufficient shares"
    And the transaction should not be recorded

  Scenario: Unauthorized user attempts to trade
    Given I am not logged in
    When I try to access the "Buy" or "Sell" functionality
    Then I should be redirected to the login page
    And I should see the message "Please sign in to continue."
