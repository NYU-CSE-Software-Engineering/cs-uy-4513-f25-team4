Feature: User Registration
  As a new user of the Investra platform
  I want to register for an account
  So that I can access the trading platform

  Background:
    Given the following roles exist:
      | name                  | description                    |
      | Trader                | Individual investor            |
      | Associate Trader      | Company employee trader        |
      | Portfolio Manager     | Company manager                |
      | System Administrator  | Platform administrator         |
    And the following companies exist:
      | name          | domain        |
      | TestCorp Inc  | testcorp.com  |

  Scenario: User successfully registers with unique email and password is hashed
    Given I am on the registration page
    When I fill in "Email" with "newuser@example.com"
    And I fill in "Password" with "SecurePass123"
    And I fill in "Password confirmation" with "SecurePass123"
    And I fill in "First name" with "John"
    And I fill in "Last name" with "Doe"
    And I press "Sign Up"
    Then I should be on the trader dashboard page
    And I should see "Registration successful"
    And I should have the role "Trader"
    And my password should be hashed in the database

  Scenario: Registration fails when email is not unique
    Given a user exists with email "existing@example.com"
    And I am on the registration page
    When I fill in "Email" with "existing@example.com"
    And I fill in "Password" with "SecurePass123"
    And I fill in "Password confirmation" with "SecurePass123"
    And I fill in "First name" with "John"
    And I fill in "Last name" with "Doe"
    And I press "Sign Up"
    Then I should see "Email is already taken"
    And I should be on the registration page

  Scenario: System assigns default Trader role upon registration
    Given I am on the registration page
    When I fill in "Email" with "trader@example.com"
    And I fill in "Password" with "SecurePass123"
    And I fill in "Password confirmation" with "SecurePass123"
    And I fill in "First name" with "Jane"
    And I fill in "Last name" with "Smith"
    And I press "Sign Up"
    Then I should be on the trader dashboard page
    Then I should have the role "Trader"
    And I should not have any other roles assigned


  Scenario: Registration fails with password less than 8 characters
    Given I am on the registration page
    When I fill in "Email" with "newuser@example.com"
    And I fill in "Password" with "Short12"
    And I fill in "Password confirmation" with "Short12"
    And I fill in "First name" with "John"
    And I fill in "Last name" with "Doe"
    And I press "Sign Up"
    Then I should see "Password is too short (minimum is 8 characters)"
    And I should be on the registration page

  Scenario: Registration fails with mismatched password confirmation
    Given I am on the registration page
    When I fill in "Email" with "newuser@example.com"
    And I fill in "Password" with "SecurePass123"
    And I fill in "Password confirmation" with "DifferentPass456"
    And I fill in "First name" with "John"
    And I fill in "Last name" with "Doe"
    And I press "Sign Up"
    Then I should see "Password confirmation doesn't match"
    And I should be on the registration page

  Scenario: Password is stored securely using hashing
    Given I am on the registration page
    When I fill in "Email" with "secure@example.com"
    And I fill in "Password" with "MySecurePass123"
    And I fill in "Password confirmation" with "MySecurePass123"
    And I fill in "First name" with "Secure"
    And I fill in "Last name" with "User"
    And I press "Sign Up"
    Then my password should be hashed in the database
    And the plain text password "MySecurePass123" should not be stored
    Then I should be on the trader dashboard page

  Scenario: Multiple users can register with different email addresses
    Given a user exists with email "first@example.com"
    And I am on the registration page
    When I fill in "Email" with "second@example.com"
    And I fill in "Password" with "SecurePass123"
    And I fill in "Password confirmation" with "SecurePass123"
    And I fill in "First name" with "Second"
    And I fill in "Last name" with "User"
    And I press "Sign Up"
    Then I should see "Registration successful"
    And I should have the role "Trader"
    And both users should exist in the system

  Scenario: Portfolio Manager registers with company email domain
    Given I am on the registration page
    When I fill in "Email" with "manager@testcorp.com"
    And I fill in "Password" with "SecurePass123"
    And I fill in "Password confirmation" with "SecurePass123"
    And I fill in "First name" with "Sarah"
    And I fill in "Last name" with "Johnson"
    And I click "Portfolio Manager"
    And I press "Sign Up"
    Then I should be on the manager dashboard page
    And I should see "Registration successful"
    And I should have the role "Portfolio Manager"
    And I should be affiliated with company "TestCorp Inc"

  Scenario: Associate Trader registers with company email domain
    Given I am on the registration page
    When I fill in "Email" with "associate@testcorp.com"
    And I fill in "Password" with "SecurePass123"
    And I fill in "Password confirmation" with "SecurePass123"
    And I fill in "First name" with "Mike"
    And I fill in "Last name" with "Chen"
    And I click "Associate Trader"
    And I fill in "Company name" with "TestCorp Inc"
    And I press "Sign Up"
    Then I should be on the associate dashboard page
    And I should see "Registration successful"
    And I should have the role "Associate Trader"
    And I should be affiliated with company "TestCorp Inc"


  Scenario: Portfolio Manager registers with a new company domain
    Given I am on the registration page
    When I fill in "Email" with "ceo@newstartup.com"
    And I fill in "Password" with "SecurePass123"
    And I fill in "Password confirmation" with "SecurePass123"
    And I fill in "First name" with "Alice"
    And I fill in "Last name" with "Martinez"
    And I click "Portfolio Manager"
    And I fill in "Company name" with "NewStartup Inc"
    And I press "Sign Up"
    Then I should be on the manager dashboard page
    And I should see "Registration successful"
    And I should have the role "Portfolio Manager"
    And a new company "NewStartup Inc" should be created with domain "newstartup.com"
    And I should be affiliated with company "NewStartup Inc"
