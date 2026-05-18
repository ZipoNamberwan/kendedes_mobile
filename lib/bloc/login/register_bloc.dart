import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/login/register_event.dart';
import 'package:kendedes_mobile/bloc/login/register_state.dart';
import 'package:kendedes_mobile/classes/api_server_handler.dart';
import 'package:kendedes_mobile/classes/repositories/auth_repository.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/user_db_repository.dart';
import 'package:kendedes_mobile/models/user.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(Initialized()) {
    on<Register>((event, emit) async {
      emit(RegisterState(data: state.data.copyWith(isLoading: true)));

      await ApiServerHandler.run(
        action: () async {
          if ((state.data.email?.isEmpty ?? true) ||
              (state.data.name?.isEmpty ?? true) ||
              (state.data.organization?.id.isEmpty ?? true) ||
              (state.data.role?.id.isEmpty ?? true)) {
            emit(
              RegisterFailed(
                'Ada field yang masih kosong',
                data: state.data.copyWith(isLoading: false),
              ),
            );
            return;
          }

          final User user = await AuthRepository().registerWithGoogle(
            email: state.data.email!,
            name: state.data.name!,
            organization: state.data.organization!.id,
            role: state.data.role!.id,
          );
          await UserDbRepository().insert(user);

          emit(RegisterSuccess(data: state.data.copyWith(isLoading: false)));
        },
        onLoginExpired: (e) {
          emit(
            RegisterFailed(
              'Sesi login telah habis, silakan login kembali',
              data: state.data.copyWith(isLoading: false),
            ),
          );
        },
        onDataProviderError: (e) {
          emit(
            RegisterFailed(
              e.message,
              data: state.data.copyWith(isLoading: false),
            ),
          );
        },
        onOtherError: (e) {
          emit(
            RegisterFailed(
              'Terjadi kesalahan: ${e.toString()}',
              data: state.data.copyWith(isLoading: false),
            ),
          );
        },
      );
    });

    on<InitFields>((event, emit) {
      final newState = state.data.copyWith(
        resetAllFields: true,
        isLoading: false,
      );
      emit(
        FieldsInitialized(
          data: newState.copyWith(
            email: event.email,
            name: event.name,
            organization: event.organization,
            role: event.role,
          ),
        ),
      );
    });

    on<UpdateNameField>((event, emit) {
      emit(RegisterState(data: state.data.copyWith(name: event.name)));
    });

    on<ChangeOrganizationField>((event, emit) {
      emit(
        RegisterState(
          data: state.data.copyWith(organization: event.organization),
        ),
      );
    });

    on<ChangeUserRoleField>((event, emit) {
      emit(RegisterState(data: state.data.copyWith(role: event.role)));
    });

    on<ChangeProfile>((event, emit) async {
      emit(RegisterState(data: state.data.copyWith(isLoading: true)));

      await ApiServerHandler.run(
        action: () async {
          if ((state.data.email?.isEmpty ?? true) ||
              (state.data.name?.isEmpty ?? true) ||
              (!event.hideOrganization &&
                  (state.data.organization?.id.isEmpty ?? true)) ||
              (!event.hideRole && (state.data.role?.id.isEmpty ?? true))) {
            emit(
              RegisterFailed(
                'Ada field yang masih kosong',
                data: state.data.copyWith(isLoading: false),
              ),
            );
            return;
          }

          final User user = await AuthRepository().changeProfile(
            email: state.data.email!,
            name: state.data.name!,
            organization:
                event.hideOrganization ? null : state.data.organization!.id,
            role: event.hideRole ? null : state.data.role!.id,
          );
          await UserDbRepository().insert(user);

          emit(RegisterSuccess(data: state.data.copyWith(isLoading: false)));
        },
        onLoginExpired: (e) {
          emit(
            RegisterFailed(
              'Sesi login telah habis, silakan login kembali',
              data: state.data.copyWith(isLoading: false),
            ),
          );
        },
        onDataProviderError: (e) {
          emit(
            RegisterFailed(
              e.message,
              data: state.data.copyWith(isLoading: false),
            ),
          );
        },
        onOtherError: (e) {
          emit(
            RegisterFailed(
              'Terjadi kesalahan: ${e.toString()}',
              data: state.data.copyWith(isLoading: false),
            ),
          );
        },
      );
    });
  }
}
