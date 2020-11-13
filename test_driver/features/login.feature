Feature: LoginScreen Validates and then Logs in
  Who? member
  What? login
  Why? authentication

  Scenario: when email and password are in specified format and login is clicked
    Given I have "_EmailInput" and "_PasswordInput" and "_LoginButton"
    When I fill the "_EmailInput" field with "test@example.com"
    And I fill the "_PasswordInput" field with "qwerty12"
    And I tap the "_LoginButton"
    Then I have "HomeScreen"

  Scenario: when login state and logout is clicked
    Given I have "_LogoutButton"
    When I tap the "_LogoutButton"
    Then I have "LoginScreen"

