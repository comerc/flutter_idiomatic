import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:flutter_idiomatic/import.dart';

void main() {
  const emailInput = EmailInputModel.dirty('email');
  const passwordInput = PasswordInputModel.dirty('password');
  group('LoginState', () {
    test('supports value comparisons', () {
      expect(LoginState(), LoginState());
    });

    test('returns same object when no properties are passed', () {
      expect(LoginState().copyWith(), LoginState());
    });

    test('returns object with updated status when status is passed', () {
      expect(
        LoginState().copyWith(status: FormzStatus.pure),
        LoginState(),
      );
    });

    test('returns object with updated email when email is passed', () {
      expect(
        LoginState().copyWith(emailInput: emailInput),
        LoginState(emailInput: emailInput),
      );
    });

    test('returns object with updated password when password is passed', () {
      expect(
        LoginState().copyWith(passwordInput: passwordInput),
        LoginState(passwordInput: passwordInput),
      );
    });
  });
}
