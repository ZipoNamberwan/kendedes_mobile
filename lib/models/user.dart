import 'package:kendedes_mobile/models/organization.dart';
import 'package:kendedes_mobile/models/user_role.dart';

class User {
  final String id;
  final String email;
  final String name;
  final Organization organization;
  final UserRole? role;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.organization,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['firstname'] as String,
      organization: Organization.fromJson(
        json['organization'] as Map<String, dynamic>,
      ),
      role:
          json['role'] != null
              ? UserRole.fromJson(json['role'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'organization': organization.toJson(),
      'role': role?.toJson(),
    };
  }
}
