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
  final String firstname;
  @HiveField(3)
  final Organization? organization;
  @HiveField(4)
  final List<UserRole> roles;

  User({
    required this.id,
    required this.email,
    required this.firstname,
    this.organization,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final rolesData = json['roles'];

    List<UserRole> parsedRoles = [];
    if (rolesData is List) {
      parsedRoles =
          rolesData
              .whereType<Map<String, dynamic>>() // ✅ recommended Dart style
              .map((e) => UserRole.fromJson(e))
              .toList();
    }
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      firstname: json['firstname'] as String,
      organization:
          json['organization'] != null
              ? Organization.fromJson(
                json['organization'] as Map<String, dynamic>,
              )
              : null,
      roles: parsedRoles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstname': firstname,
      'organization': organization?.toJson(),
      'roles': roles.map((role) => role.toJson()).toList(),
    };
  }
}
