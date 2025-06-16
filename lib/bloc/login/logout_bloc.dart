import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/login/logout_event.dart';
import 'package:kendedes_mobile/bloc/login/logout_state.dart';
import 'package:kendedes_mobile/classes/repositories/auth_repository.dart';
import 'package:kendedes_mobile/classes/services/dio_service.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  LogoutBloc()
    : super(
        Initializing(
          data: LogoutStateData(
            isLogoutLoading: false,
            isLogoutSuccess: false,
            isLogoutFailure: false,
          ),
        ),
      ) {
    on<Logout>((event, emit) async {
      emit(LogoutLoading(data: state.data.copyWith(isLogoutLoading: true)));

      try {
        await AuthRepository().logout();

        emit(
          LogoutSuccess(
            data: state.data.copyWith(
              isLogoutSuccess: true,
              isLogoutLoading: false,
            ),
          ),
        );
      } on DioException catch (dioError) {
        final err = dioError.error;

        if (err is LoginExpiredException) {
          await AuthRepository().clearToken();
          emit(
            TokenExpired(
              data: state.data.copyWith(
                isLogoutFailure: true,
                isLogoutLoading: false,
              ),
            ),
          );
        } else if (err is DataProviderException) {
          emit(
            LogoutFailed(
              errorMessage: err.message,
              data: state.data.copyWith(
                isLogoutFailure: true,
                isLogoutLoading: false,
              ),
            ),
          );
        } else {
          emit(
            LogoutFailed(
              errorMessage: 'Something went wrong: ${dioError.message}',
              data: state.data.copyWith(
                isLogoutFailure: true,
                isLogoutLoading: false,
              ),
            ),
          );
        }
      } catch (e) {
        emit(
          LogoutFailed(
            errorMessage: e.toString(),
            data: state.data.copyWith(
              isLogoutFailure: true,
              isLogoutLoading: false,
            ),
          ),
        );
      }
    });
  }
}
