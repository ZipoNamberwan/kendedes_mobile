import 'package:equatable/equatable.dart';

class LogoutState extends Equatable {
  final LogoutStateData data;

  const LogoutState({required this.data});

  @override
  List<Object> get props => [data];
}

class Initializing extends LogoutState {
  const Initializing({required super.data});
}

class LogoutLoading extends LogoutState {
  const LogoutLoading({required super.data});
}

class LogoutSuccess extends LogoutState {
  const LogoutSuccess({required super.data});
}

class LogoutFailed extends LogoutState {
  final String errorMessage;
  const LogoutFailed({required this.errorMessage, required super.data});
}

class TokenExpired extends LogoutState {
  const TokenExpired({required super.data});
}

class LogoutStateData {
  final bool isLogoutLoading;
  final bool isLogoutSuccess;
  final bool isLogoutFailure;

  LogoutStateData({
    required this.isLogoutLoading,
    required this.isLogoutSuccess,
    required this.isLogoutFailure,
  });

  LogoutStateData copyWith({
    bool? isLogoutLoading,
    bool? isLogoutSuccess,
    bool? isLogoutFailure,
  }) {
    return LogoutStateData(
      isLogoutLoading: isLogoutLoading ?? this.isLogoutLoading,
      isLogoutSuccess: isLogoutSuccess ?? this.isLogoutSuccess,
      isLogoutFailure: isLogoutFailure ?? this.isLogoutFailure,
    );
  }
}
