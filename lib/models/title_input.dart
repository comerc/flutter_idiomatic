import 'package:formz/formz.dart';
import 'package:characters/characters.dart';

class TitleInputModel extends FormzInput<String, String> {
  const TitleInputModel.pure() : super.pure('');
  TitleInputModel.dirty([String value = '']) : super.dirty(value.trim());

  @override
  String validator(String value) {
    if (value.characters.length < 4) {
      return 'Invalid input < 4 characters';
    }
    return null;
  }
}
