import 'package:equatable/equatable.dart';

class Sls extends Equatable {
  final String id;
  final String shortCode;
  final String longCode;
  final String name;
  final String villageId;

  @override
  List<Object?> get props => [id];

  const Sls({
    required this.id,
    required this.shortCode,
    required this.longCode,
    required this.name,
    required this.villageId,
  });

  factory Sls.fromJson(Map<String, dynamic> json) {
    return Sls(
      id: json['id'].toString(),
      shortCode: json['short_code'] as String,
      longCode: json['long_code'] as String,
      name: json['name'] as String,
      villageId: json['village_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'short_code': shortCode,
      'long_code': longCode,
      'name': name,
      'village_id': villageId,
    };
  }
}
