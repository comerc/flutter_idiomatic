import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:flutter_firebase_login/import.dart';

class SignUpScreen extends StatelessWidget {
  Route<T> getRoute<T>() {
    return buildRoute<T>(
      '/sign_up',
      builder: (_) => this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: BlocProvider(
        create: (BuildContext context) =>
            SignUpCubit(getRepository<AuthenticationRepository>(context)),
        child: SignUpForm(),
      ),
    );
  }
}

class SignUpForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpCubit, SignUpState>(
      listener: (BuildContext context, SignUpState state) {
        if (state.status.isSubmissionFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Sign Up Failure')),
            );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Align(
          alignment: const Alignment(0, -1 / 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _EmailInput(),
              const SizedBox(height: 8),
              _PasswordInput(),
              const SizedBox(height: 8),
              _ConfirmPasswordInput(),
              const SizedBox(height: 8),
              _SignUpButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (SignUpState previous, SignUpState current) =>
          previous.emailInput != current.emailInput,
      builder: (BuildContext context, SignUpState state) {
        return TextField(
          key: const Key('signUpForm_emailInput_textField'),
          onChanged: (String value) =>
              getBloc<SignUpCubit>(context).emailChanged(value),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'email',
            helperText: '',
            errorText: state.emailInput.invalid ? 'invalid email' : null,
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (SignUpState previous, SignUpState current) =>
          previous.passwordInput != current.passwordInput,
      builder: (BuildContext context, SignUpState state) {
        return TextField(
          key: const Key('signUpForm_passwordInput_textField'),
          onChanged: (String value) =>
              getBloc<SignUpCubit>(context).passwordChanged(value),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'password',
            helperText: '',
            errorText: state.passwordInput.invalid ? 'invalid password' : null,
          ),
        );
      },
    );
  }
}

class _ConfirmPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (SignUpState previous, SignUpState current) =>
          previous.passwordInput != current.passwordInput ||
          previous.confirmedPasswordInput != current.confirmedPasswordInput,
      builder: (context, state) {
        return TextField(
          key: const Key('signUpForm_confirmedPasswordInput_textField'),
          onChanged: (String value) =>
              context.bloc<SignUpCubit>().confirmedPasswordChanged(value),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'confirm password',
            helperText: '',
            errorText: state.confirmedPasswordInput.invalid
                ? 'passwords do not match'
                : null,
          ),
        );
      },
    );
  }
}

class _SignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      buildWhen: (SignUpState previous, SignUpState current) =>
          previous.status != current.status,
      builder: (BuildContext context, SignUpState state) {
        return state.status.isSubmissionInProgress
            ? const CircularProgressIndicator()
            : RaisedButton(
                key: const Key('signUpForm_continue_raisedButton'),
                child: Text('Sign Up'.toUpperCase()),
                shape: const StadiumBorder(),
                color: Colors.orangeAccent,
                onPressed: state.status.isValidated
                    ? () => getBloc<SignUpCubit>(context).signUpFormSubmitted()
                    : null,
              );
      },
    );
  }
}
