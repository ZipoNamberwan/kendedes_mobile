import 'package:hive_ce/hive.dart';
import 'package:kendedes_mobile/classes/helpers.dart';
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
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt:
          json['deleted_at'] != null
              ? DateTime.parse(json['deleted_at'])
              : null,
      type: ProjectType.fromKey(json['type']) ?? ProjectType.supplementMobile,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.key,
      'created_at': DateHelper.format(createdAt),
      'updated_at': DateHelper.format(updatedAt),
      'deleted_at': DateHelper.format(deletedAt),
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
    'swmaps market',
    'Sentra Ekonomi SWMaps',
  );
  static const supplementSwmaps = ProjectType._(
    'swmaps supplement',
    'Suplemen SWMaps',
  );
  static const supplementMobile = ProjectType._(
    'kendedes mobile',
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
