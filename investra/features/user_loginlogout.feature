Feature: User Login and Logout
  As a registered user of the Investra platform
  I want to log in and log out securely
  So that I can access my account and protect my information

# Login

Scenario: User successfully logs in with valid credentials
    Given a user exists with email "trader@example.com" and password "SecurePass123"
    And I am on the login page
    When I fill in "Email" with "trader@example.com"
    And I fill in "Password" with "SecurePass123"
    And I press "Log In"
    Then I should be on the trader dashboard page
    And I should see "Login successful"
    And I should be logged in as "trader@example.com"     

Scenario: Login creates a user session
    Given a user exists with email "trader@example.com" and password "SecurePass123"
    And I am on the login page
    When I fill in "Email" with "trader@example.com"
    And I fill in "Password" with "SecurePass123"
    And I press "Log In"
    Then a session should be created for "trader@example.com"
    And I should be logged in

Scenario: Login fails with invalid password
    Given a user exists with email "trader@example.com" and password "CorrectPass123"
    And I am on the login page
    When I fill in "Email" with "trader@example.com"
    And I fill in "Password" with "WrongPassword"
    And I press "Log In"
    Then I should see "Invalid email or password"
    And I should be on the login page
    And I should not be logged in

Scenario: Login fails with non-existent email
    Given I am on the login page
    When I fill in "Email" with "nonexistent@example.com"
    And I fill in "Password" with "AnyPassword123"
    And I press "Log In"
    Then I should see "Invalid email or password"
    And I should be on the login page
    And I should not be logged in

Scenario: Trader redirects to personal dashboard after login
    Given a user exists with email "trader@example.com" and password "SecurePass123" and role " Trader"
    And I am on the login page
    When I fill in "Email" with "trader@example.com"
    And I fill in "Password" with "SecurePass123"
    And I press "Log In"
    Then I should be on the trader dashboard page
    And I should see "My Portfolio"

Scenario: Associate Trader redirects to their dashboard after login
    Given a user exists with email "associate@testcorp.com" and password "SecurePass123" and role "Associate Trader"
    And I am on the login page
    When I fill in "Email" with "associate@testcorp.com"
    And I fill in "Password" with "SecurePass123"
    And I press "Log In"
    Then I should be on the associate dashboard page

Scenario: Portfolio Manager redirects to manager dashboard after login
    Given a user exists with email "manager@testcorp.com" and password "SecurePass123" and role "Portfolio Manager"
    And I am on the login page
    When I fill in "Email" with "manager@testcorp.com"
    And I fill in "Password" with "SecurePass123"
    And I press "Log In"
    Then I should be on the manager dashboard page

Scenario: System Administrator redirects to admin panel after login
    Given a user exists with email "admin@investra.com" and password "SecurePass123" and role "System Administrator"
    And I am on the login page
    When I fill in "Email" with "admin@investra.com"
    And I fill in "Password" with "SecurePass123"
    And I press "Log In"
    Then I should be on the admin dashboard page

#Logout

Scenario: User successfully logs out from dashboard
    Given I am logged in as "trader@example.com"
    And I am on the trader dashboard page
    When I click "Log Out"
    Then I should be on the login page
    And I should see "Logged out successfully"
    And I should not be logged in

Scenario: User can log out from any page
    Given I am logged in as "trader@example.com"
    And I am on the profile page
    When I click "Log Out"
    Then I should be on the login page
    And I should not be logged in

Scenario: Logout destroys user session
    Given I am logged in as "trader@example.com"
    And I am on the trader dashboard page
    When I click "Log Out"
    Then the user session should be destroyed
    And I should not have an active session
    And my session data should be cleared

#Session Management 

Scenario: User session persists across page navigation
    Given I am logged in as "trader@example.com"
    When I navigate to the profile page
    And I navigate to the trader dashboard page
    Then I should still be logged in as "trader@example.com"
    And my session should remain active

Scenario: User session expires after logout
    Given I am logged in as "trader@example.com"
    When I click "Log Out"
    Then my session should no longer exist
    And I cannot access any protected pages without logging in again