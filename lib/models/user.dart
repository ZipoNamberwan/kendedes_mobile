import 'package:hive_ce/hive.dart';
import 'package:kendedes_mobile/hive/hive_types.dart';
import 'package:kendedes_mobile/models/organization.dart';
import 'package:kendedes_mobile/models/user_role.dart';
part 'user.g.dart';

@HiveType(typeId: userTypeId)
class User extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String email;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final Organization? organization;
  @HiveField(4)
  final UserRole? role;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.organization,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['firstname'] as String,
      organization:
          json['organization'] != null
              ? Organization.fromJson(
                json['organization'] as Map<String, dynamic>,
              )
              : null,
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
      'organization': organization?.toJson(),
      'role': role?.toJson(),
    };
  }
}
