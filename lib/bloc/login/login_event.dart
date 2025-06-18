import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object?> get props => [];
}

class LoginEmailChanged extends LoginEvent {
  final String email;
  const LoginEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class LoginPasswordChanged extends LoginEvent {
  final String password;
  const LoginPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class ToggleObscurePassword extends LoginEvent {
  const ToggleObscurePassword();
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}

class InitLogin extends LoginEvent {
  const InitLogin();
}

class ThrowLoginError extends LoginEvent {
  final String message;
  const ThrowLoginError(this.message);
}

class LoginMajapahit extends LoginEvent {
  final String token;
  final Map<String, dynamic> user;
  const LoginMajapahit({required this.token, required this.user});
}

// class MockupLogin extends LoginEvent {
//   const MockupLogin();
// }
