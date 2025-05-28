import 'package:equatable/equatable.dart';

class LoginState extends Equatable {
  final LoginStateData data;

  const LoginState({required this.data});

  @override
  List<Object> get props => [data];
}

class LoginFailed extends LoginState {
  const LoginFailed({required super.data});
}

class LoginSuccess extends LoginState {
  const LoginSuccess({required super.data});
}

class LoginStateData {
  final LoginFormFieldState<String> email;
  final LoginFormFieldState<String> password;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;
  final bool obscurePassword;

  LoginStateData({
    required this.email,
    required this.password,
    required this.isSubmitting,
    required this.isSuccess,
    required this.isFailure,
    required this.obscurePassword,
  });

  LoginStateData copyWith({
    LoginFormFieldState<String>? email,
    LoginFormFieldState<String>? password,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isFailure,
    bool? obscurePassword,
    bool resetAllErrorMessages = false,
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
