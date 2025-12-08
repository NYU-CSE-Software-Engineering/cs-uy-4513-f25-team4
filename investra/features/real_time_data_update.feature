Feature: Real-time Data Update
  As a trader
  I want stock prices and market data to update automatically at fixed intervals
  So that I can make decisions based on the most current information

  Background:
    Given I am logged in as a trader
    And the following stocks exist:
      | symbol | name           | price  | available_quantity | sector     | market_cap    | description              |
      | AAPL   | Apple Inc.     | 170.50 | 10000              | Technology | 2800000000000 | A leading tech company.  |
      | GOOGL  | Alphabet Inc.  | 140.25 | 5000               | Technology | 1900000000000 | A tech conglomerate.     |

  Scenario: View last updated time on stock list page
    Given stock "AAPL" was last updated "5 minutes ago"
    When I visit the stocks page
    Then I should see "Last Updated: 5 minutes ago" for stock "AAPL"

  Scenario: View last updated time on stock detail page
    Given stock "AAPL" was last updated "10 minutes ago"
    When I visit the stock detail page for "AAPL"
    Then I should see "Last Updated: 10 minutes ago"
    And I should see "Data refreshes automatically"

  Scenario: Manually refresh stock data
    Given stock "AAPL" has a current price of "$170.50"
    When I visit the stock detail page for "AAPL"
    And I click the "Refresh Data" button
    Then the stock price should be updated
    And I should see "Data refreshed successfully"
    And the "Last Updated" time should show "just now"

  Scenario: Stock price updates automatically from external API
    Given an external stock data API is available
    And stock "AAPL" has a current price of "$170.50"
    When the system fetches latest data from the API
    Then stock "AAPL" price should be updated to the latest value
    And a new price point should be recorded
    And the "updated_at" timestamp should be current

  Scenario: Display real-time price badge on stock list
    Given stock "GOOGL" price was updated "2 minutes ago"
    When I visit the stocks page
    Then I should see a "LIVE" badge next to "GOOGL"
    And the badge should indicate "Updated 2 min ago"

  Scenario: Show data staleness warning for outdated prices
    Given stock "AAPL" price was last updated "2 hours ago"
    When I visit the stock detail page for "AAPL"
    Then I should see a warning "Price data may be outdated"
    And I should see "Last updated: 2 hours ago"
    And I should see a prominent "Refresh Now" button

  Scenario: Auto-refresh countdown timer on detail page
    Given I am on the stock detail page for "AAPL"
    Then I should see "Auto-refresh in: 60 seconds"
    When I wait for 30 seconds
    Then I should see "Auto-refresh in: 30 seconds"

  Scenario: System updates all stock prices via scheduled job
    Given the following stocks exist with outdated prices:
      | symbol | current_price | last_updated      |
      | AAPL   | 170.50        | 1 hour ago        |
      | GOOGL  | 140.25        | 1 hour ago        |
    When the scheduled stock price update job runs
    Then all stock prices should be refreshed
    And new price points should be created for each stock
    And each stock's "updated_at" should be current

