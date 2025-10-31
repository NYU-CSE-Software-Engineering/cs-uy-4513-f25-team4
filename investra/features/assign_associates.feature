Feature: Portfolio Manager Assigns Associate Role
  As a Portfolio Manager
  I want to add and remove associates
  So that I can view and manage their trading activities

Background:
    Given I am logged in as a Portfolio Manager
    And my company is "Test Corp Inc"
    And I am on the "Manage Team" page

Scenario: Successfully assign a trader as associate
    Given the following users exist:
    | Email                | Role    | Company |
    | john@email.com       | Trader  | None    |
    When I click "Add Associate"
    And I select user "john@email.com" from the available traders list
    And I click "Assign as Associate"
    Then I should see "Associate added successfully"
    And "john@email.com" should appear in my associates list
    And the user "john@email.com" should have role "Associate Trader"
    And the user should be associated with company "Test Corp Inc"

Scenario: Remove associate from my team
    Given an associate "remove@email.com" exists in my team
    When I click "Remove" for associate "remove@email.com"
    And I confirm the removal
    Then I should see "Associate removed successfully"
    And "remove@email.com" should not appear in my associates list
    And the user "remove@email.com" should have role "Trader"
    And the user should not be associated with any company

Scenario: Search for trader by name
    Given the following users exist:
    | Email                | First Name | Last Name | Role    |
    | alice@email.com      | Alice      | Smith     | Trader  |
    | bob@email.com        | Alice      | Perry     | Trader  |
    | charlie@email.com    | Charlie    | Jones     | Trader  |
    When I click "Add Associate"
    And I search for "Alice"
    Then I should see 2 traders
    And I should see "alice@email.com"
    And I should see "bob@email.com"
    And I should not see "charlie@email.com"