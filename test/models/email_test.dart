// ignore_for_file: prefer_const_constructors
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_firebase_login/import.dart';

void main() {
  const emailString = 'test@gmail.com';
  group('Email', () {
    group('constructors', () {
      test('pure creates correct instance', () {
        final email = EmailInputModel.pure();
        expect(email.value, '');
        expect(email.pure, true);
      });

      test('dirty creates correct instance', () {
        final email = EmailInputModel.dirty(emailString);
        expect(email.value, emailString);
        expect(email.pure, false);
      });
    });

    group('validator', () {
      test('returns invalid error when email is empty', () {
        expect(
          EmailInputModel.dirty('').error,
          EmailInputValidationError.invalid,
        );
      });

      test('returns invalid error when email is malformed', () {
        expect(
          EmailInputModel.dirty('test').error,
          EmailInputValidationError.invalid,
        );
      });

      test('is valid when email is valid', () {
        expect(
          EmailInputModel.dirty(emailString).error,
          isNull,
        );
      });
    });
  });
}
