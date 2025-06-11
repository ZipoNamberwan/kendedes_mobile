import 'package:equatable/equatable.dart';

abstract class LogoutEvent extends Equatable {
  const LogoutEvent();
  @override
  List<Object?> get props => [];
}

class Logout extends LogoutEvent {
  const Logout();
}