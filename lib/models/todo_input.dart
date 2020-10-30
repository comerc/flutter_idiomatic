import 'package:formz/formz.dart';
import 'package:characters/characters.dart';

class TodoInputModel extends FormzInput<String, String> {
  const TodoInputModel.pure() : super.pure('');
  TodoInputModel.dirty([String value = '']) : super.dirty(value.trim());

  @override
  String validator(String value) {
    if (value.characters.length < 4) {
      return 'Invalid Todo < 4 characters';
    }
    return null;
  }
}
