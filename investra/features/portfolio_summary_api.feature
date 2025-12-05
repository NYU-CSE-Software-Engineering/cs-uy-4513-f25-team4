Feature: Portfolio summary API/UI
  As a logged-in trader
  I want to view my portfolio summary
  So I can see holdings and total value

  Background:
    Given a trader exists with email "trader@example.com" and balance 10000
    And a stock exists with symbol "AAPL" price 150 and quantity 1000
    And the trader owns 5 shares of "AAPL"
    And I am logged in as that trader

  Scenario: View portfolio summary page
    When I am on the "Portfolio" page
    Then I should see "AAPL"
    And I should see "Holdings Snapshot"
