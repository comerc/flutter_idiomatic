import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:flutter_firebase_login/import.dart';

part 'github_repositories.g.dart';

class GitHubRepositoriesCubit extends HydratedCubit<GitHubRepositoriesState> {
  GitHubRepositoriesCubit(this.repository)
      : assert(repository != null),
        super(GitHubRepositoriesState());

  final GitHubRepository repository;

  Future<void> reset() async {
    emit(GitHubRepositoriesState());
  }

  Future<bool> load() async {
    emit(state.copyWith(status: GitHubStatus.busy));
    try {
      final items = await repository.readRepositories();
      emit(state.copyWith(
        items: items,
        status: GitHubStatus.ready,
      ));
    } on Exception {
      return false;
    } finally {
      emit(state.copyWith(status: GitHubStatus.ready));
    }
    return true;
  }

  List<RepositoryModel> _updateStarLocally(String id, bool value) {
    final index =
        state.items.indexWhere((RepositoryModel item) => item.id == id);
    if (index == -1) {
      return state.items;
    }
    final items = [...state.items];
    items[index] = items[index].copyWith(viewerHasStarred: value);
    return items;
  }

  Future<bool> toggleStar({String id, bool value}) async {
    emit(state.copyWith(
      items: _updateStarLocally(id, value),
      loadingItems: {...state.loadingItems}..add(id),
    ));
    try {
      await repository.toggleStar(id: id, value: value);
    } on Exception {
      emit(state.copyWith(
        items: _updateStarLocally(id, !value),
      ));
      return false;
    } finally {
      emit(state.copyWith(
        loadingItems: {...state.loadingItems}..remove(id),
      ));
    }
    return true;
  }

  @override
  GitHubRepositoriesState fromJson(Map<String, dynamic> json) =>
      GitHubRepositoriesState.fromJson(json);

  @override
  Map<String, dynamic> toJson(GitHubRepositoriesState state) => state.toJson();
}

enum GitHubStatus { initial, busy, ready }

@CopyWith()
@JsonSerializable()
class GitHubRepositoriesState extends Equatable {
  GitHubRepositoriesState({
    this.items = const [],
    this.status = GitHubStatus.initial,
    this.loadingItems = const {},
  }) : assert(items != null);

  final List<RepositoryModel> items;
  final GitHubStatus status;
  final Set<String> loadingItems;

  @override
  List<Object> get props => [items, status, loadingItems];

  factory GitHubRepositoriesState.fromJson(Map<String, dynamic> json) =>
      _$GitHubRepositoriesStateFromJson(json);

  Map<String, dynamic> toJson() => _$GitHubRepositoriesStateToJson(this);
}
