Feature: Display Price Trend Graph for Selected Stock
  As a trader
  I want to view price trend graphs for stocks with different timeframes
  So that I can analyze price movements and identify trading patterns

  Background:
    Given I am logged in as a trader
    And the following stocks exist:
      | symbol | name           | price  | available_quantity | sector     | market_cap | description              |
      | AAPL   | Apple Inc.     | 170.50 | 10000              | Technology | 2800000000000 | A leading tech company. |

  @javascript
  Scenario: View default price trend graph on stock detail page
    Given stock "AAPL" has price history for the last 30 days
    When I visit the stock detail page for "AAPL"
    Then I should see a price trend graph
    And the graph should display "30-day" timeframe by default

  @javascript
  Scenario: Switch to weekly price trend view
    Given stock "AAPL" has price history for the last 7 days
    When I visit the stock detail page for "AAPL"
    And I click on "Week" timeframe button
    Then the graph should display "7-day" data
    And I should see price points for the last 7 days

  @javascript
  Scenario: Switch to monthly price trend view
    Given stock "AAPL" has price history for the last 30 days
    When I visit the stock detail page for "AAPL"
    And I click on "Month" timeframe button
    Then the graph should display "30-day" data
    And I should see price points for the last 30 days

  @javascript
  Scenario: Switch to yearly price trend view
    Given stock "AAPL" has price history for the last 365 days
    When I visit the stock detail page for "AAPL"
    And I click on "Year" timeframe button
    Then the graph should display "365-day" data
    And I should see price points for the last 365 days

  @javascript
  Scenario: Graph displays correct price data
    Given stock "AAPL" has the following price history:
      | date       | price  |
      | 2025-12-01 | 165.00 |
      | 2025-12-02 | 167.50 |
      | 2025-12-03 | 169.00 |
      | 2025-12-04 | 170.50 |
    When I visit the stock detail page for "AAPL"
    Then the graph should show price "165.00" for date "2025-12-01"
    And the graph should show price "167.50" for date "2025-12-02"
    And the graph should show price "169.00" for date "2025-12-03"
    And the graph should show price "170.50" for date "2025-12-04"

  Scenario: No graph shown when no price history exists
    Given stock "AAPL" has no price history
    When I visit the stock detail page for "AAPL"
    Then I should see "No price data available for chart"
    And I should not see a price trend graph

