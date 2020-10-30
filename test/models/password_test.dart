// ignore_for_file: prefer_const_constructors
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_firebase_login/import.dart';

void main() {
  const passwordString = 'T0pS3cr3t123';

  group('Password', () {
    group('constructors', () {
      test('pure creates correct instance', () {
        final password = PasswordInputModel.pure();
        expect(password.value, '');
        expect(password.pure, true);
      });

      test('dirty creates correct instance', () {
        final password = PasswordInputModel.dirty(passwordString);
        expect(password.value, passwordString);
        expect(password.pure, false);
      });
    });

    group('validator', () {
      test('returns invalid error when password is empty', () {
        expect(
          PasswordInputModel.dirty('').error,
          PasswordInputValidationError.invalid,
        );
      });

      test('is valid when password is not empty', () {
        expect(
          PasswordInputModel.dirty(passwordString).error,
          isNull,
        );
      });
    });
  });
}
