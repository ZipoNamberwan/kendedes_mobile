import 'package:kendedes_mobile/classes/helpers.dart';
import 'package:kendedes_mobile/models/interaction_mode.dart';
import 'package:kendedes_mobile/models/user.dart';

class Project {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final ProjectType type;
  final User? user;

  final InteractionMode interactionMode;

  final String remoteId;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.type,
    this.user,
    required this.interactionMode,
    required this.remoteId,
  });

  factory Project.fromServerJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      remoteId: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt:
          json['deleted_at'] != null
              ? DateTime.parse(json['deleted_at'])
              : null,
      type: ProjectType.fromKey(json['type']) ?? ProjectType.supplementMobile,
      user:
          json['user'] != null
              ? User.fromJson(json['user'] as Map<String, dynamic>)
              : null,
      interactionMode: InteractionMode.tag,
    );
  }

  factory Project.fromLocalDbJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      remoteId: json['remote_id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt:
          json['deleted_at'] != null
              ? DateTime.parse(json['deleted_at'])
              : null,
      type: ProjectType.fromKey(json['type']) ?? ProjectType.supplementMobile,
      user:
          json['user'] != null
              ? User.fromJson(json['user'] as Map<String, dynamic>)
              : null,
      interactionMode:
          InteractionMode.fromKey(json['interaction_mode']) ??
          InteractionMode.browse,
    );
  }

  Map<String, dynamic> toServerJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.key,
      'created_at': DateHelper.format(createdAt),
      'updated_at': DateHelper.format(updatedAt),
      'deleted_at': DateHelper.format(deletedAt),
      'interaction_mode': interactionMode.key,
    };
  }

  Map<String, dynamic> toLocalDbJson() {
    return {
      'id': id,
      'remote_id': remoteId,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'type': type.key,
      'user_id': user?.id,
      'interaction_mode': interactionMode.key,
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
    User? user,
    InteractionMode? interactionMode,
    String? remoteId,
  }) {
    return Project(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      type: type ?? this.type,
      user: user ?? this.user,
      interactionMode: interactionMode ?? this.interactionMode,
    );
  }
}

class ProjectType {
  final String key;
  final String text;

  const ProjectType({required this.key, required this.text});

  const ProjectType._(this.key, this.text);

  static const marketSwmaps = ProjectType._(
    'swmaps market',
    'Sentra Ekonomi (SWMaps)',
  );
  static const supplementSwmaps = ProjectType._(
    'swmaps supplement',
    'Kendedes Mobile (SWMaps)',
  );
  static const supplementMobile = ProjectType._(
    'kendedes mobile',
    'Kendedes Mobile',
  );
  static const wilkerstat = ProjectType._('wilkerstat', 'Suplemen Wilkerstat');
  static const jenggala = ProjectType._('jenggala', 'Jenggala');
  static const survey = ProjectType._('survey', 'Survei BPS');
  static const sbr = ProjectType._('sbr', 'SBR');
  static const agriculture = ProjectType._('agriculture', 'ST2023');
  static const eform = ProjectType._('eform', 'E-Form Jatim 2025');
  static const other = ProjectType._('other', 'Lainnya');
  // static const browse = ProjectType._('browse', 'Browse Mode');

  static const values = [
    marketSwmaps,
    supplementSwmaps,
    supplementMobile,
    // wilkerstat,
    // jenggala,
    survey,
    sbr,
    agriculture,
    eform,
    // other,
  ];

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
