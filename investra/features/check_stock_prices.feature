Feature: Check Real-time and Historical Prices of Stocks
  As a trader
  I want to check current and historical stock prices
  So that I can make informed trading decisions based on price trends

  Background:
    Given I am logged in as a trader
    And the following stocks exist with price history:
      | symbol | name           | current_price |
      | AAPL   | Apple Inc.     | 170.50        |
      | GOOGL  | Alphabet Inc.  | 140.25        |

  Scenario: View current stock price on stock list
    When I visit the stocks page
    Then I should see "AAPL" with current price "$170.50"
    And I should see "GOOGL" with current price "$140.25"

  Scenario: View real-time price on stock detail page
    When I visit the stock detail page for "AAPL"
    Then I should see "Current Price: $170.50"
    And I should see "Last Updated:" followed by a timestamp

  Scenario: View historical price data
    Given stock "AAPL" has the following price history:
      | price  | recorded_at         |
      | 165.00 | 2025-12-01 09:00:00 |
      | 167.50 | 2025-12-02 09:00:00 |
      | 169.00 | 2025-12-03 09:00:00 |
      | 170.50 | 2025-12-04 09:00:00 |
    When I visit the stock detail page for "AAPL"
    And I click on "Price History"
    Then I should see a price history table
    And I should see the following prices in order:
      | Date       | Price   |
      | 2025-12-04 | $170.50 |
      | 2025-12-03 | $169.00 |
      | 2025-12-02 | $167.50 |
      | 2025-12-01 | $165.00 |

  Scenario: View price range over last 30 days
    Given stock "GOOGL" has daily prices for the last 30 days
    When I visit the stock detail page for "GOOGL"
    Then I should see "30-Day Price Range"
    And I should see "High: $" followed by a price
    And I should see "Low: $" followed by a price
    And I should see "Average: $" followed by a price

  Scenario: Check price change indicator
    Given stock "AAPL" had a closing price of "$165.00" yesterday
    And stock "AAPL" has current price of "$170.50"
    When I visit the stocks page
    Then I should see "AAPL" with price change "+$5.50 (+3.33%)"
    And the price change should be displayed in green

  Scenario: View price updated timestamp
    Given stock "AAPL" price was last updated "5 minutes ago"
    When I visit the stock detail page for "AAPL"
    Then I should see "Last Updated: 5 minutes ago"

