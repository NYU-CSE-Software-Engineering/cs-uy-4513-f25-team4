Feature: Market Data viewing and interactions
  As a signed-in trader user
  I want to view company information, historical prices, price trend graphs, model predictions, and related news
  So that I can make assessments about a stock

  Background:
    Given the following stocks exist:
      | symbol | name            | price  |
      | AMZN   | Amazon.com Inc  | 150.00 |
    And the current time is "2025-10-20 12:00:00 EST"

  Scenario: User views a stock detail page with all data available (happy path)
    Given I am a signed-in user
    And there are price points for "AMZN" covering the last year, month, and week
    And there are three recent news for "AMZN"
    And there is a prediction for "AMZN" with horizon "1month"
    When I visit the stock detail page for "AMZN"
    Then I should see the title "Amazon.com Inc"
    And I should see a current price
    And I should see a price trend graph
    And I should see controls labeled "Day", "Week", "Month", "Year"
    And I should see the prediction summary
    And I should see the recent news list with 3 items

  @javascript
  Scenario: User switches the timeframe to update the price trend graph
    Given I am viewing the stock detail page for "AMZN"
    And there are price points for "AMZN" covering the last year, month, and week
    Then I should see the price trend graph showing the last 365 days
    When I click the "Day" button
    Then I should see the price trend graph showing the last 1 days
    When I click the "Week" button
    Then I should see the price trend graph showing the last 7 days
    When I click the "Month" button
    Then I should see the price trend graph showing the last 30 days
    When I click the "Year" button
    Then I should see the price trend graph showing the last 365 days

  Scenario: User stays on the stock detail page whule price feed updates
    Given there are price points for "AMZN" at "2025-09-30 11:00:00 EST" and "2025-10-01 12:00:00 EST"
    When I visit the stock detail page for "AMZN"
    Then I should see the latest price recorded at "2025-10-10 12:00:00 EST"
    When a new price point for "AMZN" is created at "2025-10-10 12:01:00 EST"
    And I refresh the page
    Then I should see the latest price recorded at "2025-10-10 12:01:00 EST"

  Scenario: User views a stock when its prediction is unavailable (sad path)
    Given there are price points for "AMZN" covering the last year, month, and week
    And there is no prediction for "AMZN"
    When I visit the stock detail page for "AMZN"
    Then I should see "Prediction unavailable" within the prediction section

  Scenario: User views a stock when news source fails to load and page shows fallback message
    Given there are price points for "AMZN" covering the last year, month, and week
    And the news feed is empty for "AMZN"
    When I visit the stock detail page for "AMZN"
    Then I should see "No Recent News Available"

  Scenario: User views a newly launched stock with no historical price data (edge case)
    Given a new stock "NEW" exists with ticker "NEW"
    And there are no price points for "NEW"
    When I visit the stock detail page for "NEW"
    Then I should see "No price data available"
    And I should see an empty price trend graph
