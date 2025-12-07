Feature: View Stock Company Information and Market News
  As a trader
  I want to view stock company information and recent market news
  So that I can make informed trading decisions

  Background:
    Given I am logged in as a trader
    And the following stocks exist:
      | symbol | name           | price  |
      | AAPL   | Apple Inc.     | 150.00 |
      | GOOGL  | Alphabet Inc.  | 2800.00|
      | MSFT   | Microsoft Corp | 300.00 |

  Scenario: View list of all available stocks
    When I visit the stocks page
    Then I should see "AAPL"
    And I should see "Apple Inc."
    And I should see "$150.00"
    And I should see "GOOGL"
    And I should see "Alphabet Inc."
    And I should see "MSFT"
    And I should see "Microsoft Corp"

  Scenario: View detailed stock information
    Given stock "AAPL" has the following company information:
      | sector     | Technology        |
      | market_cap | 2500000000000     |
    When I visit the stocks page
    And I click on "AAPL"
    Then I should see "Apple Inc."
    And I should see "Technology"
    And I should see "Market Cap"

  Scenario: View recent market news for a stock
    Given stock "AAPL" has the following news articles:
      | title                    | published_at        | source |
      | Apple launches new iPhone| 2025-12-01 10:00:00 | TechCrunch |
      | Apple Q4 earnings report | 2025-11-30 09:00:00 | Bloomberg  |
    When I visit the stocks page
    And I click on "AAPL"
    Then I should see "Apple launches new iPhone"
    And I should see "TechCrunch"
    And I should see "Apple Q4 earnings report"
    And I should see "Bloomberg"

