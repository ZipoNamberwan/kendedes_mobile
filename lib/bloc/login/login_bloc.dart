import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc()
    : super(
        LoginState(
          data: LoginStateData(
            isSubmitting: false,
            isSuccess: false,
            isFailure: false,
            obscurePassword: true,
            email: LoginFormFieldState<String>(),
            password: LoginFormFieldState<String>(),
          ),
        ),
      ) {
    on<LoginEmailChanged>((event, emit) {
      emit(
        LoginState(
          data: state.data.copyWith(
            email: state.data.email.copyWith(value: event.email, error: null),
          ),
        ),
      );
    });
    on<LoginPasswordChanged>((event, emit) {
      emit(
        LoginState(
          data: state.data.copyWith(
            password: state.data.password.copyWith(
              value: event.password,
              error: null,
            ),
          ),
        ),
      );
    });

    on<ToggleObscurePassword>((event, emit) {
      emit(
        LoginState(
          data: state.data.copyWith(
            obscurePassword: !state.data.obscurePassword,
          ),
        ),
      );
    });

    on<MockupLogin>((event, emit) async {
      emit(
        LoginState(
          data: state.data.copyWith(
            isSubmitting: true,
            resetAllErrorMessages: true,
            isSuccess: false,
            isFailure: false,
          ),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      emit(LoginSuccess(data: state.data.copyWith(isSuccess: true)));
    });

    on<LoginSubmitted>((event, emit) async {
      emit(
        LoginState(
          data: state.data.copyWith(
            isSubmitting: true,
            resetAllErrorMessages: true,
            isSuccess: false,
            isFailure: false,
          ),
        ),
      );

      // Input validation
      String? emailError;
      String? passwordError;

      final email = state.data.email.value;
      final password = state.data.password.value;

      if (email == null || email.isEmpty) {
        emailError = 'Email kosong';
      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        emailError = 'Email tidak valid';
      }

      if (password == null || password.isEmpty) {
        passwordError = 'Password kosong';
      }

      if (emailError != null || passwordError != null) {
        emit(
          LoginState(
            data: state.data.copyWith(
              isSubmitting: false,
              isFailure: true,
              isSuccess: false,
              email: state.data.email.copyWith(error: emailError),
              password: state.data.password.copyWith(error: passwordError),
            ),
          ),
        );
        return;
      }
      // Simulate login delay and logic
      await Future.delayed(const Duration(seconds: 1));
      if (state.data.email.value == 'a@bps.go.id' &&
          state.data.password.value == '123456') {
        emit(LoginSuccess(data: state.data.copyWith(isSuccess: true)));
      } else {
        emit(
          LoginFailed(
            data: state.data.copyWith(
              isFailure: true,
              isSubmitting: false,
              password: state.data.password.copyWith(
                error: 'Email atau password salah',
              ),
            ),
          ),
        );
      }
    });
  }
}
