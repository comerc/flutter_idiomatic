import 'package:json_annotation/json_annotation.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';

part 'todo.g.dart';

@CopyWith()
@JsonSerializable()
class TodoModel extends Equatable {
  TodoModel({
    this.id,
    this.title,
    this.createdAt,
  });

  final int id;
  final String title;
  final DateTime createdAt;

  @override
  List<Object> get props => [id, title, createdAt];

  factory TodoModel.fromJson(Map<String, dynamic> json) =>
      _$TodoModelFromJson(json);

  Map<String, dynamic> toJson() => _$TodoModelToJson(this);
}
