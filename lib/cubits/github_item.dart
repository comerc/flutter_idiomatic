import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:flutter_firebase_login/import.dart';

class GitHubItemCubit extends Cubit<GitHubItemState> {
  GitHubItemCubit(this.gitHubRepository, {RepositoryModel item})
      : assert(gitHubRepository != null),
        super(GitHubItemState(item: item));

  final GitHubRepository gitHubRepository;

  Future<void> toggleStar({String id, bool value}) async {
    emit(state.copyWith(status: GitHubItemStatus.loading));
    await Future.delayed(Duration(seconds: 4));
    emit(state.copyWith(status: GitHubItemStatus.ready));
  }
}

enum GitHubItemStatus { loading, error, ready }

class GitHubItemState extends Equatable {
  const GitHubItemState({
    @required this.item,
    this.status = GitHubItemStatus.ready,
  }) : assert(item != null);

  final RepositoryModel item;
  final GitHubItemStatus status;

  @override
  List<Object> get props => [item, status];

  GitHubItemState copyWith({
    RepositoryModel item,
    GitHubItemStatus status,
  }) {
    return GitHubItemState(
      item: item ?? this.item,
      status: status ?? this.status,
    );
  }
}
