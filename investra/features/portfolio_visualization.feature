Feature: User Portfolio Analytics Dashboard
  As a registered investor
  I want to view portfolio analytics and simulate hypothetical investments
  So that I can understand my performance and potential gains

  Background:
    Given I am a signed-in user

  Scenario: View portfolio trend graph with date filter
    Given I have trading history in my portfolio
    When I visit the analytics dashboard
    And I select "Last 3 Months" from the date range filter
    Then I should see a line chart displaying my portfolio value over time
    And the chart should update for the selected date range

  Scenario: View profit/loss summary per stock
    Given I have multiple holdings
    When I view the profit/loss section
    Then I should see each stock’s gain or loss in dollars and percent
    And positive returns should appear in green and negative in red

  Scenario: View portfolio diversification pie chart
    Given I have stocks from multiple sectors
    When I view the diversification chart
    Then I should see each sector represented with a percentage of my 
total balance

  Scenario: Run a valid what-if simulation
    Given I am on the analytics simulation page
    When I enter "TSLA" as the stock symbol
    And I enter "5000" as the investment amount
    And I select "2025-07-01" as the purchase date
    And I press "Simulate"
    Then I should see "Your $5,000 investment in TSLA would now be worth"
    And I should see the percent return displayed

  Scenario: Fail to run simulation with invalid input
    Given I am on the analytics simulation page
    When I leave the stock symbol blank
    And I press "Simulate"
    Then I should see "Please enter a valid stock symbol"

