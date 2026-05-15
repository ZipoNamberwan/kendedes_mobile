class UserRole {
  final String id;
  final String name;

  UserRole({required this.id, required this.name});

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(id: json['id'].toString(), name: json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  static final List<UserRole> staticUserRoles = [
    UserRole(id: 'pcl', name: 'PCL'),
    UserRole(id: 'pml', name: 'PML'),
  ];
}
