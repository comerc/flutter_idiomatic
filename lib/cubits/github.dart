import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_firebase_login/import.dart';

class GitHubCubit extends Cubit<GitHubState> {
  GitHubCubit(this.gitHubRepository)
      : assert(gitHubRepository != null),
        super(GitHubState());

  final GitHubRepository gitHubRepository;

  Future<bool> loadRepositories() async {
    var result = true;
    emit(state.copyWith(status: GitHubStatus.busy));
    try {
      final repositories = await gitHubRepository.readRepositories();
      emit(GitHubState());
      await Future.delayed(const Duration(milliseconds: 300));
      emit(state.copyWith(
        repositories: repositories,
        status: GitHubStatus.ready,
      ));
    } catch (error) {
      result = false;
    }
    return result;
  }

  List<RepositoryModel> _updateStarLocally(String id, bool value) {
    final index = state.repositories
        .indexWhere((RepositoryModel repository) => repository.id == id);
    if (index == -1) {
      return state.repositories;
    }
    final repositories = [...state.repositories];
    final repository = repositories[index];
    repositories[index] = repository.copyWith(viewerHasStarred: value);
    return repositories;
  }

  Future<bool> toggleStar({String id, bool value}) async {
    var result = true;
    emit(state.copyWith(
      repositories: _updateStarLocally(id, value),
      loadingRepositories: {...state.loadingRepositories}..add(id),
    ));
    try {
      await gitHubRepository.toggleStar(id: id, value: value);
    } catch (error) {
      emit(state.copyWith(
        repositories: _updateStarLocally(id, !value),
      ));
      result = false;
    } finally {
      emit(state.copyWith(
        loadingRepositories: {...state.loadingRepositories}..remove(id),
      ));
    }
    return result;
  }
}

enum GitHubStatus { initial, busy, ready }

class GitHubState extends Equatable {
  const GitHubState({
    this.repositories = const [],
    this.status = GitHubStatus.initial,
    this.loadingRepositories = const {},
  }) : assert(repositories != null);

  final List<RepositoryModel> repositories;
  final GitHubStatus status;
  final Set<String> loadingRepositories;

  @override
  List<Object> get props => [repositories, status, loadingRepositories];

  GitHubState copyWith({
    List<RepositoryModel> repositories,
    GitHubStatus status,
    Set<String> loadingRepositories,
  }) {
    return GitHubState(
      repositories: repositories ?? this.repositories,
      status: status ?? this.status,
      loadingRepositories: loadingRepositories ?? this.loadingRepositories,
    );
  }
}
