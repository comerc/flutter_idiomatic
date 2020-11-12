Feature: LoginScreen Validates and then Logs in

  Scenario: when email and password are in specified format and login is clicked
    Given I have "_EmailInput" key and "_PasswordInput" key and "_LoginButton" key
    When I fill the "_EmailInput" field with "test@example.com"
    And I fill the "_PasswordInput" field with "qwerty12"
    And I tap the "_LoginButton" key
    Then I have "HomeScreen" type

  Scenario: when login state and logout is clicked
    Given I have "_LogoutButton" key
    When I tap the "_LogoutButton" key
    Then I have "LoginScreen" type

