import 'package:kendedes_mobile/models/project.dart';
import 'package:latlong2/latlong.dart';

class TagData {
  final String id;
  final LatLng position;
  final bool hasChanged;
  final TagType type;
  final LatLng? initialPosition;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final int? incrementalId;
  final Project? project;

  TagData({
    required this.id,
    required this.position,
    required this.hasChanged,
    required this.type,
    this.initialPosition,
    required this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.incrementalId,
    this.project,
  });
}

enum TagType { auto, manual, move }
