import 'package:hive_ce/hive.dart';
import 'package:kendedes_mobile/hive/hive_types.dart';

part 'organization.g.dart';

@HiveType(typeId: organizationTypeId)
class Organization extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String shortCode;
  @HiveField(2)
  final String longCode;
  @HiveField(3)
  final String name;

  Organization({
    required this.id,
    required this.name,
    required this.shortCode,
    required this.longCode,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'].toString(),
      name: json['name'] as String,
      shortCode: json['short_code'] as String,
      longCode: json['long_code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'short_code': shortCode,
      'long_code': longCode,
    };
  }
}
