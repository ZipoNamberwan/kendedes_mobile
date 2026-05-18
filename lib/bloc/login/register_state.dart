import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/models/organization.dart';
import 'package:kendedes_mobile/models/user_role.dart';

class RegisterState extends Equatable {
  final RegisterStateData data;

  const RegisterState({required this.data});

  @override
  List<Object> get props => [data];
}

class Initialized extends RegisterState {
  Initialized() : super(data: RegisterStateData(isLoading: false));
}

class FieldsInitialized extends RegisterState {
  const FieldsInitialized({required super.data});
}

class RegisterSuccess extends RegisterState {
  const RegisterSuccess({required super.data});
}

class RegisterFailed extends RegisterState {
  final String errorMessage;
  const RegisterFailed(this.errorMessage, {required super.data});
}

class RegisterStateData {
  final String? email;
  final String? name;
  final Organization? organization;
  final UserRole? role;
  final bool isLoading;

  RegisterStateData({
    this.email,
    this.name,
    this.organization,
    this.role,
    required this.isLoading,
  });

  RegisterStateData copyWith({
    String? email,
    String? name,
    Organization? organization,
    UserRole? role,
    bool? isLoading,
    bool? resetAllFields,
  }) {
    return RegisterStateData(
      email: resetAllFields == true ? null : email ?? this.email,
      name: resetAllFields == true ? null : name ?? this.name,
      organization:
          resetAllFields == true ? null : organization ?? this.organization,
      role: resetAllFields == true ? null : role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
