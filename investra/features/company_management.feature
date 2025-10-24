Feature: Manage company data
  As an admin
  I want to add and update company profiles
  So that the stock information stays accurate across the platform

  Background:
    Given I am logged in as an admin

  Scenario: Successfully create a new company
    Given I am on the new company page
    When I fill in "Name" with "Tesla, Inc."
    And I fill in "Ticker" with "TSLA"
    And I fill in "Sector" with "Technology"
    And I press "Create Company"
    Then I should see "Company was successfully created"

  Scenario: Fail to create a company with a duplicate ticker
    Given an existing company with ticker "TSLA"
    And I am on the new company page
    When I fill in "Name" with "Another Tesla"
    And I fill in "Ticker" with "TSLA"
    And I press "Create Company"
    Then I should see "Ticker has already been taken"

  Scenario: Non-admin cannot access management pages
    Given I am logged in as a non-admin user
    When I visit the companies management page
    Then I should see "You are not authorized to access this page"