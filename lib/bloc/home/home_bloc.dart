import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/home/home_event.dart';
import 'package:kendedes_mobile/bloc/home/home_state.dart';
import 'package:kendedes_mobile/classes/repositories/auth_repository.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc()
    : super(
        HomeState(data: HomeStateData(currentUser: null, isLoading: true)),
      ) {
    on<Initialize>((event, emit) async {
      try {
        emit(InitializingStarted(data: state.data.copyWith(isLoading: true)));

        final user = AuthRepository().getUser();
        emit(
          InitializingSuccess(
            data: state.data.copyWith(currentUser: user, isLoading: false),
          ),
        );
      } catch (e) {
        emit(InitializingError(data: state.data, errorMessage: e.toString()));
        return;
      }
    });
  }
}
