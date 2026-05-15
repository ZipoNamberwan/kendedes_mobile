import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/models/organization.dart';
import 'package:kendedes_mobile/models/user_role.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();
  @override
  List<Object?> get props => [];
}

class InitFields extends RegisterEvent {
  final String? email;
  final String? name;
  const InitFields({this.email, this.name});
}

class Register extends RegisterEvent {
  const Register();
}

class UpdateNameField extends RegisterEvent {
  final String name;
  const UpdateNameField({required this.name});

  @override
  List<Object?> get props => [name];
}

class ChangeOrganizationField extends RegisterEvent {
  final Organization organization;
  const ChangeOrganizationField({required this.organization});

  @override
  List<Object?> get props => [organization];
}

class ChangeUserRoleField extends RegisterEvent {
  final UserRole role;
  const ChangeUserRoleField({required this.role});

  @override
  List<Object?> get props => [role];
}
