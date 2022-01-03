import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'todo.g.dart';

@CopyWith()
@JsonSerializable()
class TodoModel extends Equatable {
  TodoModel({
    required this.id,
    required this.title,
    required this.createdAt,
  });

  final int id;
  final String title;
  final DateTime createdAt;

  @override
  List<Object> get props => [id, title, createdAt];

  static TodoModel fromJson(Map<String, dynamic> json) =>
      _$TodoModelFromJson(json);

  Map<String, dynamic> toJson() => _$TodoModelToJson(this);
}
