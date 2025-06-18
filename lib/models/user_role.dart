import 'package:hive_ce/hive.dart';
import 'package:kendedes_mobile/hive/hive_types.dart';
part 'user_role.g.dart';

@HiveType(typeId: userRoleTypeId)
class UserRole extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;

  UserRole({required this.id, required this.name});

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(id: json['id'].toString(), name: json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
