Feature: System Administrator Changes User Role
    As a System Administrator
    I want to change user roles directly
    So that I can promote and demote users on behalf of the organization

Background:
    Given I am logged in as a System Administrator
    And I am on the "User Management" page

Scenario: Successfully promote Trader to Portfolio Manager
    Given a user "alice@email.com" exists with the following details:
    | Field      | Value  |
    | Role       | Trader |
    | First Name | Alice  |
    | Last Name  | Smith  |
    And a company "Test Corp Inc" exists
    When I click "Edit" for user "alice@email.com"
    And I select "Portfolio Manager" from the role dropdown
    And I select company "Test Corp Inc"
    And I click "Save Changes"
    Then I should see "Role updated successfully"
    And the user "alice@email.com" should have role "Portfolio Manager"
    And the user should be associated with company "Test Corp Inc"

Scenario: Successfully assign Trader to become Associate under a manager
    Given a user "bob@email.com" exists with role "Trader"
    And a Portfolio Manager "manager@firm.com" exists at company "Test Corp Inc"
    When I click "Edit" for user "bob@email.com"
    And I select "Associate Trader" from the role dropdown
    And I select manager "manager@firm.com"
    And I click "Save Changes"
    Then I should see "Role updated successfully"
    And the user "bob@email.com" should have role "Associate Trader"
    And the user should be managed by "manager@firm.com"
    And the user should be associated with company "Test Corp Inc"

 Scenario: Successfully promote Associate Trader to Portfolio Manager
    Given a user "charlie@email.com" exists with role "Associate Trader"
    And the user is managed by "oldmanager@firm.com"
    And the user is associated with company "Old Company"
    And a company "Test Corp Inc" exists
    When I click "Edit" for user "charlie@email.com"
    And I select "Portfolio Manager" from the role dropdown
    And I select company "Test Corp Inc"
    And I click "Save Changes"
    Then I should see "Role updated successfully"
    And the user "charlie@email.com" should have role "Portfolio Manager"
    And the user should be associated with company "Test Corp Inc"

