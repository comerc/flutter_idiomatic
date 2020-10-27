import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
// import 'package:minsk8/import.dart';

part 'todo.g.dart';

@JsonSerializable()
class TodoModel extends Equatable {
  TodoModel({
    this.id,
    this.title,
    this.isCompleted,
  });

  final int id;
  final String title;
  final bool isCompleted;

  @override
  List<Object> get props => [id, title, isCompleted];

  factory TodoModel.fromJson(Map<String, dynamic> json) =>
      _$TodoModelFromJson(json);

  Map<String, dynamic> toJson() => _$TodoModelToJson(this);

  TodoModel copyWith({
    int id,
    String title,
    bool isCompleted,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
