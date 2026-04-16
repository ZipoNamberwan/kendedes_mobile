import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/models/user.dart';

class HomeState extends Equatable {
  final HomeStateData data;

  const HomeState({required this.data});

  @override
  List<Object> get props => [data];
}

class InitializingStarted extends HomeState {
  const InitializingStarted({required super.data});
}

class InitializingSuccess extends HomeState {
  const InitializingSuccess({required super.data});
}

class InitializingError extends HomeState {
  final String errorMessage;
  const InitializingError({required super.data, required this.errorMessage});
}

class HomeStateData {
  final User? currentUser;
  final bool isLoading;

  HomeStateData({this.currentUser, required this.isLoading});

  HomeStateData copyWith({User? currentUser, bool? isLoading}) {
    return HomeStateData(
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
