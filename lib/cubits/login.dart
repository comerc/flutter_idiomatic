import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_idiomatic/import.dart';

part 'login.g.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(AuthenticationRepository repository)
      : assert(repository != null),
        _repository = repository,
        super(LoginState());

  final AuthenticationRepository _repository;

  void doEmailChanged(String value) {
    final emailInput = EmailInputModel.dirty(value);
    emit(state.copyWith(
      emailInput: emailInput,
      status: Formz.validate([emailInput, state.passwordInput]),
    ));
  }

  void doPasswordChanged(String value) {
    final passwordInput = PasswordInputModel.dirty(value);
    emit(state.copyWith(
      passwordInput: passwordInput,
      status: Formz.validate([state.emailInput, passwordInput]),
    ));
  }

  Future<void> logInWithCredentials() async {
    if (!state.status.isValidated) return;
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      await _repository.logInWithEmailAndPassword(
        email: state.emailInput.value,
        password: state.passwordInput.value,
      );
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    } on LogInWithEmailAndPasswordFailure catch (e) {
      emit(state.copyWith(
        errorMessage: e.message,
        status: FormzStatus.submissionFailure,
      ));
    } catch (_) {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }

  Future<void> logInWithGoogle() async {
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      await _repository.logInWithGoogle();
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    } on LogInWithGoogleFailure catch (e) {
      emit(state.copyWith(
        errorMessage: e.message,
        status: FormzStatus.submissionFailure,
      ));
    } catch (_) {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }
}

@CopyWith()
class LoginState extends Equatable {
  const LoginState({
    this.emailInput = const EmailInputModel.pure(),
    this.passwordInput = const PasswordInputModel.pure(),
    this.status = FormzStatus.pure,
    this.errorMessage,
  });

  final EmailInputModel emailInput;
  final PasswordInputModel passwordInput;
  // https://github.com/numen31337/copy_with_extension/pull/23
  // TODO: @CopyWithField(required: true)
  final FormzStatus status;
  final String? errorMessage;

  @override
  List<Object?> get props {
    return [
      emailInput,
      passwordInput,
      status,
      errorMessage,
    ];
  }
}
