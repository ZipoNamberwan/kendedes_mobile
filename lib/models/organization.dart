
class Organization {
  final String id;
  final String shortCode;
  final String longCode;
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
