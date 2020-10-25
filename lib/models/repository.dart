import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
// import 'package:minsk8/import.dart';

part 'repository.g.dart';

@JsonSerializable()
class RepositoryModel extends Equatable {
  RepositoryModel({
    this.id,
    this.name,
    this.viewerHasStarred,
  });

  final String id;
  final String name;
  final bool viewerHasStarred;

  @override
  List<Object> get props => [id, name, viewerHasStarred];

  factory RepositoryModel.fromJson(Map<String, dynamic> json) =>
      _$RepositoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$RepositoryModelToJson(this);
}
