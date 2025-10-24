Feature: Simulate Sell Value
  As a portfolio owner
  I want to simulate how much I would earn if I sold my entire portfolio now
  So that I can make informed decisions about whether to sell or hold my investments after considering taxes and transaction fees

  Background:
    Given I am a signed-in user
    And I have an existing portfolio with multiple stocks
    And I am on the "My Portfolio" page

  # Happy Path
  Scenario: User successfully simulates sell value
    When I click on "Simulate Sell Value"
    Then I should see a breakdown of my portfolio's gross value
    And I should see taxes and transaction fees deducted
    And I should see the final estimated return after deductions
    And I should see the confirmation message
      """
      If you sold your portfolio today, your estimated return after taxes and fees would be $XX,XXX.XX.
      """

  # Sad Path #1
  Scenario: Portfolio is empty
    Given I have no stocks in my portfolio
    When I click on "Simulate Sell Value"
    Then I should see an error message
      """
      Simulation unavailable — please check your portfolio or try again later.
      """

  # Sad Path #2
  Scenario: Market data unavailable
    Given market data for one or more stocks is missing
    When I click on "Simulate Sell Value"
    Then I should see an error message
      """
      Simulation unavailable — please check your portfolio or try again later.
      """

  # Sad Path #3
  Scenario: Calculation error occurs
    Given a backend calculation error occurs
    When I click on "Simulate Sell Value"
    Then I should see an alert message
      """
      Unable to complete simulation at this time. Please try again later.
      """
