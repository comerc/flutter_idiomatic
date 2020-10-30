import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:flutter_firebase_login/import.dart';

part 'sign_up.g.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(this.authenticationRepository)
      : assert(authenticationRepository != null),
        super(const SignUpState());

  final AuthenticationRepository authenticationRepository;

  void emailChanged(String value) {
    final email = EmailInputModel.dirty(value);
    emit(state.copyWith(
      email: email,
      status: Formz.validate([
        email,
        state.password,
        state.confirmedPassword,
      ]),
    ));
  }

  void passwordChanged(String value) {
    final password = PasswordInputModel.dirty(value);
    final confirmedPassword = ConfirmedPasswordInputModel.dirty(
      password: password.value,
      value: state.confirmedPassword.value,
    );
    emit(state.copyWith(
      password: password,
      confirmedPassword: confirmedPassword,
      status: Formz.validate([
        state.email,
        password,
        state.confirmedPassword,
      ]),
    ));
  }

  void confirmedPasswordChanged(String value) {
    final confirmedPassword = ConfirmedPasswordInputModel.dirty(
      password: state.password.value,
      value: value,
    );
    emit(state.copyWith(
      confirmedPassword: confirmedPassword,
      status: Formz.validate([
        state.email,
        state.password,
        confirmedPassword,
      ]),
    ));
  }

  Future<void> signUpFormSubmitted() async {
    if (!state.status.isValidated) return;
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      await authenticationRepository.signUp(
        email: state.email.value,
        password: state.password.value,
      );
      emit(state.copyWith(status: FormzStatus.submissionSuccess));
    } on Exception {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }
}

@CopyWith()
class SignUpState extends Equatable {
  const SignUpState({
    this.email = const EmailInputModel.pure(),
    this.password = const PasswordInputModel.pure(),
    this.confirmedPassword = const ConfirmedPasswordInputModel.pure(),
    this.status = FormzStatus.pure,
  });

  final EmailInputModel email;
  final PasswordInputModel password;
  final ConfirmedPasswordInputModel confirmedPassword;
  final FormzStatus status;

  @override
  List<Object> get props => [email, password, confirmedPassword, status];
}
