import 'package:kendedes_mobile/models/organization.dart';

class User {
  final String id;
  final String email;
  final String name;
  final Organization organization;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.organization,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['firstname'] as String,
      organization: Organization.fromJson(
        json['organization'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'organization': organization.toJson(),
    };
  }
}
