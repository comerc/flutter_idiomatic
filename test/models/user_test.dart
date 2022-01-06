import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_idiomatic/import.dart';

void main() {
  group('User', () {
    const id = 'mock-id';
    const email = 'mock-email';

    test('uses value equality', () {
      expect(
        UserModel(email: email, id: id),
        equals(UserModel(email: email, id: id)),
      );
    });

    test('isEmpty returns true for empty user', () {
      expect(UserModel.empty.isEmpty, isTrue);
    });

    test('isEmpty returns false for non-empty user', () {
      final user = UserModel(email: email, id: id);
      expect(user.isEmpty, isFalse);
    });

    test('isNotEmpty returns false for empty user', () {
      expect(UserModel.empty.isNotEmpty, isFalse);
    });

    test('isNotEmpty returns true for non-empty user', () {
      final user = UserModel(email: email, id: id);
      expect(user.isNotEmpty, isTrue);
    });
  });
}
