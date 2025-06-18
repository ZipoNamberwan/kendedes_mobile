import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/classes/api_server_handler.dart';
import 'package:kendedes_mobile/classes/repositories/auth_repository.dart';
import 'package:kendedes_mobile/models/user.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc()
    : super(
        Initializing(
          data: LoginStateData(
            isSubmitting: false,
            isSuccess: false,
            isFailure: false,
            obscurePassword: true,
            email: LoginFormFieldState<String>(),
            password: LoginFormFieldState<String>(),
            isLogoutLoading: false,
            isLogoutSuccess: false,
            isLogoutFailure: false,
          ),
        ),
      ) {
    on<InitLogin>((event, emit) async {
      emit(Initializing(data: state.data.copyWith(isSubmitting: true)));
      if (AuthRepository().isTokenExists()) {
        emit(
          LoginSuccess(
            data: state.data.copyWith(isSuccess: true, isSubmitting: false),
          ),
        );
      } else {
        emit(LoginState(data: state.data.copyWith(isSubmitting: false)));
      }
    });

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

      await ApiServerHandler.run(
        action: () async {
          emit(LoginState(data: state.data.copyWith(isSubmitting: true)));
          await AuthRepository().login(email: email!, password: password!);
          emit(
            LoginSuccess(
              data: state.data.copyWith(isSuccess: true, isSubmitting: false),
            ),
          );
        },
        onLoginExpired: (e) {},
        onDataProviderError: (e) {
          emit(
            LoginFailed(
              errorMessage: e.message,
              data: state.data.copyWith(
                isSubmitting: false,
                isFailure: true,
                isSuccess: false,
              ),
            ),
          );
        },
        onOtherError: (e) {
          emit(
            LoginFailed(
              errorMessage: e.toString(),
              data: state.data.copyWith(
                isSubmitting: false,
                isFailure: true,
                isSuccess: false,
              ),
            ),
          );
        },
      );
    });

    on<ThrowLoginError>((event, emit) {
      emit(
        LoginFailed(
          errorMessage: event.message,
          data: state.data.copyWith(isSubmitting: false),
        ),
      );
    });

    on<LoginMajapahit>((event, emit) async {
      try {
        await AuthRepository().saveToken(event.token);
        await AuthRepository().saveUser(User.fromJson(event.user));

        emit(LoginSuccess(data: state.data.copyWith(isSuccess: true)));
      } catch (e) {
        emit(
          LoginFailed(
            errorMessage: 'Gagal menyimpan data pengguna: ${e.toString()}',
            data: state.data.copyWith(isSubmitting: false, isFailure: true),
          ),
        );
      }
    });
  }
}
