import 'package:equatable/equatable.dart';

class LoginState extends Equatable {
  final LoginStateData data;

  const LoginState({required this.data});

  @override
  List<Object> get props => [data];
}

class Initializing extends LoginState {
  const Initializing({required super.data});
}

class LoginFailed extends LoginState {
  final String errorMessage;
  const LoginFailed({required this.errorMessage, required super.data});
}

class LoginSuccess extends LoginState {
  const LoginSuccess({required super.data});
}

class TokenExpired extends LoginState {
  const TokenExpired({required super.data});
}

class LoginStateData {
  final LoginFormFieldState<String> email;
  final LoginFormFieldState<String> password;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;
  final bool obscurePassword;

  /// State for logout process
  final bool isLogoutLoading;
  final bool isLogoutSuccess;
  final bool isLogoutFailure;

  LoginStateData({
    required this.email,
    required this.password,
    required this.isSubmitting,
    required this.isSuccess,
    required this.isFailure,
    required this.obscurePassword,
    required this.isLogoutLoading,
    required this.isLogoutSuccess,
    required this.isLogoutFailure,
  });

  LoginStateData copyWith({
    LoginFormFieldState<String>? email,
    LoginFormFieldState<String>? password,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isFailure,
    bool? obscurePassword,
    bool resetAllErrorMessages = false,
    bool? isLogoutLoading,
    bool? isLogoutSuccess,
    bool? isLogoutFailure,
  }) {
    return LoginStateData(
      email:
          resetAllErrorMessages
              ? this.email.clearError()
              : (email ?? this.email),
      password:
          resetAllErrorMessages
              ? this.password.clearError()
              : (password ?? this.password),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      isLogoutLoading: isLogoutLoading ?? this.isLogoutLoading,
      isLogoutSuccess: isLogoutSuccess ?? this.isLogoutSuccess,
      isLogoutFailure: isLogoutFailure ?? this.isLogoutFailure,
    );
  }
}

class LoginFormFieldState<T> {
  final T? value;
  final String? error;

  LoginFormFieldState({this.value, this.error});

  LoginFormFieldState<T> copyWith({T? value, String? error}) {
    return LoginFormFieldState<T>(value: value ?? this.value, error: error);
  }

  LoginFormFieldState<T> clearError() => copyWith(error: null);
}
