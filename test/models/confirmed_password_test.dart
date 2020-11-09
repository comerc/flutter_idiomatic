import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_firebase_login/import.dart';

void main() {
  const confirmedPasswordString = 'T0pS3cr3t123';
  const passwordString = 'T0pS3cr3t123';
  const password = PasswordInputModel.dirty(passwordString);
  group('confirmedPassword', () {
    group('constructors', () {
      test('pure creates correct instance', () {
        final confirmedPassword = ConfirmedPasswordInputModel.pure();
        expect(confirmedPassword.value, '');
        expect(confirmedPassword.pure, true);
      });

      test('dirty creates correct instance', () {
        final confirmedPassword = ConfirmedPasswordInputModel.dirty(
          password: password.value,
          value: confirmedPasswordString,
        );
        expect(confirmedPassword.value, confirmedPasswordString);
        expect(confirmedPassword.password, password.value);
        expect(confirmedPassword.pure, false);
      });
    });

    group('validator', () {
      test('returns invalid error when confirmedPassword is empty', () {
        expect(
          ConfirmedPasswordInputModel.dirty(password: password.value).error,
          ConfirmedPasswordInputValidationError.invalid,
        );
      });

      test('is valid when confirmedPassword is not empty', () {
        expect(
          ConfirmedPasswordInputModel.dirty(
            password: password.value,
            value: confirmedPasswordString,
          ).error,
          isNull,
        );
      });
    });
  });
}
