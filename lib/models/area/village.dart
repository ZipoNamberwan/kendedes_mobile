import 'package:equatable/equatable.dart';

class Village extends Equatable {
  final String id;
  final String shortCode;
  final String longCode;
  final String name;
  final String subdistrictId;

  @override
  List<Object?> get props => [id];

  const Village({
    required this.id,
    required this.shortCode,
    required this.longCode,
    required this.name,
    required this.subdistrictId,
  });

  factory Village.fromJson(Map<String, dynamic> json) {
    return Village(
      id: json['id'].toString(),
      shortCode: json['short_code'] as String,
      longCode: json['long_code'] as String,
      name: json['name'] as String,
      subdistrictId: json['subdistrict_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'short_code': shortCode,
      'long_code': longCode,
      'name': name,
      'subdistrict_id': subdistrictId,
    };
  }
}
