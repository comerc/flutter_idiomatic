import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:flutter_firebase_login/import.dart';

class GitHubCubit extends Cubit<GitHubState> {
  GitHubCubit(this.gitHubRepository)
      : assert(gitHubRepository != null),
        super(GitHubInitial());

  final GitHubRepository gitHubRepository;

  Future<void> readRepositories() async {
    emit(GitHubLoadInProgress());
    try {
      final repositories = await gitHubRepository.readRepositories();
      emit(GitHubLoadSuccess(repositories: repositories));
    } catch (error) {
      emit(GitHubLoadFailure());
    }
  }

  Future<void> toggleStar({String id, bool value}) async {
    return null;
  }
}

abstract class GitHubState extends Equatable {
  const GitHubState();

  @override
  List<Object> get props => [];
}

class GitHubInitial extends GitHubState {}

class GitHubLoadInProgress extends GitHubState {}

class GitHubLoadSuccess extends GitHubState {
  const GitHubLoadSuccess({
    @required this.repositories,
  }) : assert(repositories != null);

  final List<RepositoryModel> repositories;

  @override
  List<Object> get props => [repositories];
}

class GitHubLoadFailure extends GitHubState {}
