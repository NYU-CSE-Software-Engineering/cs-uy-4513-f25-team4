Feature: Watchlist API/UI
  As a logged-in trader
  I want to manage my watchlist
  So I can track symbols I care about

  Background:
    Given a trader exists with email "watcher@example.com" and balance 5000
    And I am logged in as that trader

  Scenario: Add a symbol to my watchlist
    When I am on the "Watchlist" page
    And I fill in "symbol" with "MSFT"
    And I press "Add"
    Then I should see "MSFT"
