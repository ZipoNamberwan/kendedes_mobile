import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class Initialize extends HomeEvent {
  const Initialize();

  @override
  List<Object?> get props => [];
}
