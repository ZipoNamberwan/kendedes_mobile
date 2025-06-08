import 'package:hive_ce/hive.dart';
import 'package:kendedes_mobile/hive/hive_types.dart';
part 'project.g.dart';

@HiveType(typeId: projectTypeId)
class Project {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final DateTime createdAt;
  @HiveField(4)
  final DateTime updatedAt;
  @HiveField(5)
  final DateTime? deletedAt;
  @HiveField(6)
  final ProjectType type;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.type,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      deletedAt:
          json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      type: ProjectType.fromJson(json['type']) ?? ProjectType.supplementMobile,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  Project copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    ProjectType? type,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      type: type ?? this.type,
    );
  }
}

@HiveType(typeId: projectTypeTypeId)
class ProjectType {
  @HiveField(0)
  final String key;
  @HiveField(1)
  final String text;

  const ProjectType({required this.key, required this.text});

  const ProjectType._(this.key, this.text);

  static const marketSwmaps = ProjectType._(
    'market_swmaps',
    'Sentra Ekonomi SWMaps',
  );
  static const supplementSwmaps = ProjectType._(
    'supplement_swmaps',
    'Suplemen SWMaps',
  );
  static const supplementMobile = ProjectType._(
    'supplement_mobile',
    'Suplemen Mobile',
  );

  static const values = [marketSwmaps, supplementSwmaps, supplementMobile];

  static ProjectType? fromKey(String key) {
    return values.where((item) => item.key == key).firstOrNull;
  }

  static List<ProjectType> getProjectTypes() {
    return values;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'key': key, 'text': text};
  }

  /// Parse from JSON (returns null if key not found)
  static ProjectType? fromJson(Map<String, dynamic> json) {
    return fromKey(json['key']);
  }
}
