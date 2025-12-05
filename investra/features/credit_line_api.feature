Feature: Credit line API/UI
  As a logged-in trader
  I want to view my credit line
  So I can track limit, used, and available

  Background:
    Given a trader exists with email "credit@example.com" and balance 0
    And that trader has a credit line with limit 10000 and used 2500
    And I am logged in as that trader

  Scenario: View credit line summary
    When I visit the credit line page
    Then I should see "Credit Line Overview"
    And I should see "10,000.00"
    And I should see "7,500.00"
