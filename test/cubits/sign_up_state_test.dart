import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:flutter_idiomatic/import.dart';

void main() {
  const emailInput = EmailInputModel.dirty('email');
  const passwordString = 'password';
  const passwordInput = PasswordInputModel.dirty(passwordString);
  const confirmedPassword = ConfirmedPasswordInputModel.dirty(
    password: passwordString,
    value: passwordString,
  );

  group('SignUpState', () {
    test('supports value comparisons', () {
      expect(SignUpState(), SignUpState());
    });

    test('returns same object when no properties are passed', () {
      expect(SignUpState().copyWith(), SignUpState());
    });

    test('returns object with updated status when status is passed', () {
      expect(
        SignUpState().copyWith(status: FormzStatus.pure),
        SignUpState(),
      );
    });

    test('returns object with updated email when email is passed', () {
      expect(
        SignUpState().copyWith(emailInput: emailInput),
        SignUpState(emailInput: emailInput),
      );
    });

    test('returns object with updated password when password is passed', () {
      expect(
        SignUpState().copyWith(passwordInput: passwordInput),
        SignUpState(passwordInput: passwordInput),
      );
    });

    test(
        'returns object with updated confirmedPassword'
        ' when confirmedPassword is passed', () {
      expect(
        SignUpState().copyWith(confirmedPasswordInput: confirmedPassword),
        SignUpState(confirmedPasswordInput: confirmedPassword),
      );
    });
  });
}
