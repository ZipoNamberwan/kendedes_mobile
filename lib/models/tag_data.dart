import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:kendedes_mobile/models/area/sls.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/models/survey.dart';
import 'package:kendedes_mobile/models/user.dart';
import 'package:latlong2/latlong.dart';

class TagData {
  final String id;
  final double positionLat;
  final double positionLng;
  final bool hasChanged;
  final bool hasSentToServer;
  final TagType type;
  final double initialPositionLat;
  final double initialPositionLng;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final int? incrementalId;
  final Project project;
  final bool isLocked;

  // Attributes for the supplement tag data
  final String businessName;
  final String? businessOwner;
  final String? businessAddress;
  final BuildingStatus? buildingStatus;
  final String? description;
  final Sector? sector;
  final String? note;
  final User? user;
  final Survey? survey;

  // ID in server
  final String remoteId;

  // Attribute Area
  final Sls? sls;

  TagData({
    required this.id,
    required this.positionLat,
    required this.positionLng,
    required this.hasChanged,
    required this.hasSentToServer,
    required this.type,
    required this.initialPositionLat,
    required this.initialPositionLng,
    required this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.incrementalId,
    required this.project,
    required this.user,
    required this.isLocked,

    // Supplement tag data
    required this.businessName,
    this.businessOwner,
    this.businessAddress,
    required this.buildingStatus,
    this.description,
    required this.sector,
    this.note,
    this.survey,

    // ID in server
    required this.remoteId,

    // Area
    this.sls,
  });

  TagData copyWith({
    String? id,
    double? positionLat,
    double? positionLng,
    bool? hasChanged,
    bool? hasSentToServer,
    TagType? type,
    double? initialPositionLat,
    double? initialPositionLng,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? incrementalId,
    Project? project,
    User? user,
    String? businessName,
    String? businessOwner,
    String? businessAddress,
    BuildingStatus? buildingStatus,
    String? description,
    Sector? sector,
    String? note,
    Survey? survey,
    bool? isLocked,
    String? remoteId,
    Sls? sls,
  }) {
    return TagData(
      id: id ?? this.id,
      positionLat: positionLat ?? this.positionLat,
      positionLng: positionLng ?? this.positionLng,
      hasChanged: hasChanged ?? this.hasChanged,
      hasSentToServer: hasSentToServer ?? this.hasSentToServer,
      type: type ?? this.type,
      initialPositionLat: initialPositionLat ?? this.initialPositionLat,
      initialPositionLng: initialPositionLng ?? this.initialPositionLng,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      incrementalId: incrementalId ?? this.incrementalId,
      project: project ?? this.project,
      user: user ?? this.user,
      businessName: businessName ?? this.businessName,
      businessOwner: businessOwner ?? this.businessOwner,
      businessAddress: businessAddress ?? this.businessAddress,
      buildingStatus: buildingStatus ?? this.buildingStatus,
      description: description ?? this.description,
      sector: sector ?? this.sector,
      note: note ?? this.note,
      survey: survey ?? this.survey,
      isLocked: isLocked ?? this.isLocked,
      remoteId: remoteId ?? this.remoteId,
      sls: sls ?? this.sls,
    );
  }

  String getTagLabel(String? selectedField) {
    switch (selectedField) {
      case 'name_owner':
        return businessName +
            (businessOwner != null ? ' <$businessOwner>' : '');
      case 'name':
        return businessName;
      case 'owner':
        return businessOwner ?? '';
      case 'sector':
        return sector?.key ?? '';
      default:
        return businessName +
            (businessOwner != null ? ' <$businessOwner>' : '');
    }
  }

  Color getColorScheme(String currentProjectId, String currentUserId) {
    if (project.type.key == ProjectType.marketSwmaps.key) {
      return Colors.purple;
    } else if (project.type.key == ProjectType.supplementSwmaps.key) {
      return Colors.indigo;
    } else if (project.type.key == ProjectType.survey.key) {
      return Colors.pink;
    } else if (project.type.key == ProjectType.supplementMobile.key) {
      if (currentProjectId == project.id) {
        return Colors.deepOrange;
      } else if (currentUserId == user?.id) {
        return Colors.amber;
      }

      return Colors.cyan;
    } else {
      return Colors.grey;
    }
  }

  Color getBrowseColorScheme() {
    if (project.type.key == ProjectType.marketSwmaps.key) {
      return Colors.purple;
    } else if (project.type.key == ProjectType.survey.key) {
      return Colors.pink;
    } else if (project.type.key == ProjectType.supplementMobile.key ||
        project.type.key == ProjectType.supplementSwmaps.key) {
      return Colors.cyan;
    } else if (project.type.key == ProjectType.agriculture.key) {
      return Colors.green;
    } else if (project.type.key == ProjectType.eform.key) {
      return Colors.yellow;
    } else {
      return Colors.grey;
    }
  }

  bool shouldSentToServer(String currentProjectId) {
    if (currentProjectId == project.id) {
      return !hasSentToServer;
    }
    return false;
  }

  bool canBeDeleted(String currentProjectId) {
    if (currentProjectId == project.id) {
      return !isLocked;
    }
    return false;
  }

  bool showCloudIcon(String currentProjectId) {
    if (currentProjectId == project.id) {
      return true;
    }
    return false;
  }

  /// Calculate distance in meters from this business position to a given location.
  /// Returns null if business position is (0, 0) or the given location is null.
  double? distanceTo(LatLng? currentLocation) {
    if (currentLocation == null) return null;
    if (positionLat == 0 && positionLng == 0) return null;

    const double earthRadius = 6371000; // meters
    final dLat = _toRadians(currentLocation.latitude - positionLat);
    final dLng = _toRadians(currentLocation.longitude - positionLng);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(positionLat)) *
            cos(_toRadians(currentLocation.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degrees) => degrees * pi / 180;

  /// Convert to JSON to sent to server
  Map<String, dynamic> toServerJson() {
    return {
      'id': id,
      'latitude': positionLat,
      'longitude': positionLng,
      'name': businessName,
      'owner': businessOwner,
      'address': businessAddress,
      'building': buildingStatus?.text,
      'description': description,
      'sector': sector?.text,
      'note': note,
      'project': {
        'id': project.id,
        'name': project.name,
        'description': project.description,
      },
      'user': user?.id,
      'organization': user?.organization?.id,
    };
  }

  /// Convert to JSON to store in local db
  Map<String, dynamic> toLocalDbJson() {
    return {
      'id': id,
      'remote_id': remoteId,
      'position_lat': positionLat,
      'position_lng': positionLng,
      'has_changed': hasChanged ? 1 : 0,
      'has_sent_to_server': hasSentToServer ? 1 : 0,
      'tag_type': type.name,
      'initial_position_lat': initialPositionLat,
      'initial_position_lng': initialPositionLng,
      'is_deleted': isDeleted ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'incremental_id': incrementalId,
      'project_id': project.id,
      'business_name': businessName,
      'business_owner': businessOwner,
      'business_address': businessAddress,
      'building_status': buildingStatus?.key,
      'description': description,
      'sector': sector?.key,
      'note': note,
      'user_id': user?.id,
      'is_locked': isLocked ? 1 : 0,

      // save area to local db
      'sls_id': sls?.id,
      'sls_short_code': sls?.shortCode,
      'sls_long_code': sls?.longCode,
      'sls_name': sls?.name,
      'village_id': sls?.village?.id,
      'village_short_code': sls?.village?.shortCode,
      'village_long_code': sls?.village?.longCode,
      'village_name': sls?.village?.name,
      'subdistrict_id': sls?.village?.subdistrict?.id,
      'subdistrict_short_code': sls?.village?.subdistrict?.shortCode,
      'subdistrict_long_code': sls?.village?.subdistrict?.longCode,
      'subdistrict_name': sls?.village?.subdistrict?.name,
      'regency_id': sls?.village?.subdistrict?.regency?.id,
      'regency_short_code': sls?.village?.subdistrict?.regency?.shortCode,
      'regency_long_code': sls?.village?.subdistrict?.regency?.longCode,
      'regency_name': sls?.village?.subdistrict?.regency?.name,
    };
  }

  /// Parse from Server JSON
  factory TagData.fromServerJson(Map<String, dynamic> json) {
    return TagData(
      id: json['id'] as String,
      remoteId: json['id'] as String,
      positionLat: double.tryParse(json['latitude'].toString()) ?? 0.0,
      positionLng: double.tryParse(json['longitude'].toString()) ?? 0.0,
      hasChanged: false,
      hasSentToServer: true,
      isLocked: json['is_locked'],
      type: TagType.auto,
      initialPositionLat: double.tryParse(json['latitude'].toString()) ?? 0.0,
      initialPositionLng: double.tryParse(json['longitude'].toString()) ?? 0.0,
      isDeleted: json['deleted_at'] != null,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      deletedAt:
          json['deleted_at'] != null
              ? DateTime.parse(json['deleted_at'] as String)
              : null,
      incrementalId: 1,
      project: Project.fromServerJson(json['project'] as Map<String, dynamic>),
      businessName: json['name'] as String,
      businessOwner: json['owner'] as String?,
      businessAddress: json['address'] as String?,
      buildingStatus:
          json['status'] != null
              ? BuildingStatus.fromKey(
                json['status'].toString().toLowerCase().replaceAll(' ', '_'),
              )
              : null,
      description: json['description'] as String,
      sector:
          (() {
            final sectorStr = json['sector']?.toString();
            return sectorStr != null && sectorStr.isNotEmpty
                ? Sector.fromKey(sectorStr[0].toUpperCase())
                : null;
          })(),
      note: json['note'] as String?,
      user:
          json['user'] != null
              ? User.fromJson(json['user'] as Map<String, dynamic>)
              : null,
      survey:
          json['survey'] != null
              ? Survey.fromJson(json['survey'] as Map<String, dynamic>)
              : null,

      // area from server json is nested in sls
      sls:
          json['sls'] != null
              ? Sls.fromSameLevelServerJson(
                json['sls'] as Map<String, dynamic>,
                json['village'] as Map<String, dynamic>,
                json['subdistrict'] as Map<String, dynamic>,
                json['regency'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  /// Parse from JSON from local db
  factory TagData.fromLocalDbJson(
    Map<String, dynamic> map,
    User? user,
    Project project,
  ) {
    return TagData(
      id: map['id'],
      remoteId: map['remote_id'],
      positionLat: map['position_lat'],
      positionLng: map['position_lng'],
      hasChanged: map['has_changed'] == 1,
      hasSentToServer: map['has_sent_to_server'] == 1,
      type: TagType.values.firstWhere((e) => e.name == map['tag_type']),
      initialPositionLat: map['initial_position_lat'],
      initialPositionLng: map['initial_position_lng'],
      isDeleted: map['is_deleted'] == 1,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      deletedAt:
          map['deleted_at'] != null ? DateTime.parse(map['deleted_at']) : null,
      incrementalId: map['incremental_id'],
      project: project,
      businessName: map['business_name'],
      businessOwner: map['business_owner'],
      businessAddress: map['business_address'],
      buildingStatus: BuildingStatus.values.firstWhere(
        (e) => e.key == map['building_status'],
      ),
      description: map['description'],
      sector: Sector.values.firstWhere((e) => e.key == map['sector']),
      note: map['note'],
      isLocked: map['is_locked'] == 1,
      user:
          user ??
          User(id: '', email: '', firstname: '', organization: null, roles: []),

      // area from from local db
      sls: Sls.fromLocalDbJson(map),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TagData && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'TagData(id: $id, businessName: $businessName)';
}

enum TagType { auto, manual, move }

class Sector extends Equatable {
  final String key;
  final String text;

  const Sector({required this.key, required this.text});

  const Sector._(this.key, this.text);

  static const A = Sector._('A', 'A. Pertanian, Kehutanan dan Perikanan');
  static const B = Sector._('B', 'B. Pertambangan dan Penggalian');
  static const C = Sector._('C', 'C. Industri Pengolahan');
  static const D = Sector._(
    'D',
    'D. Pengadaan Listrik, Gas, Uap/Air Panas Dan Udara Dingin',
  );
  static const E = Sector._(
    'E',
    'E. Treatment Air, Treatment Air Limbah, Treatment dan Pemulihan Material Sampah, dan Aktivitas Remediasi',
  );
  static const F = Sector._('F', 'F. Konstruksi');
  static const G = Sector._(
    'G',
    'G. Perdagangan Besar Dan Eceran, Reparasi Dan Perawatan Mobil Dan Sepeda Motor',
  );
  static const H = Sector._('H', 'H. Pengangkutan dan Pergudangan');
  static const I = Sector._(
    'I',
    'I. Penyediaan Akomodasi Dan Penyediaan Makan Minum',
  );
  static const J = Sector._('J', 'J. Informasi Dan Komunikasi');
  static const K = Sector._('K', 'K. Aktivitas Keuangan dan Asuransi');
  static const L = Sector._('L', 'L. Real Estat');
  static const M = Sector._('M', 'M. Aktivitas Profesional, Ilmiah Dan Teknis');
  static const N = Sector._(
    'N',
    'N. Aktivitas Penyewaan dan Sewa Guna Usaha Tanpa Hak Opsi, Ketenagakerjaan, Agen Perjalanan dan Penunjang Usaha Lainnya',
  );
  static const O = Sector._(
    'O',
    'O. Administrasi Pemerintahan, Pertahanan Dan Jaminan Sosial Wajib',
  );
  static const P = Sector._('P', 'P. Pendidikan');
  static const Q = Sector._(
    'Q',
    'Q. Aktivitas Kesehatan Manusia Dan Aktivitas Sosial',
  );
  static const R = Sector._('R', 'R. Kesenian, Hiburan Dan Rekreasi');
  static const S = Sector._('S', 'S. Aktivitas Jasa Lainnya');
  static const T = Sector._(
    'T',
    'T. Aktivitas Rumah Tangga Sebagai Pemberi Kerja; Aktivitas Yang Menghasilkan Barang Dan Jasa Oleh Rumah Tangga yang Digunakan untuk Memenuhi Kebutuhan Sendiri',
  );
  static const U = Sector._(
    'U',
    'U. Aktivitas Badan Internasional Dan Badan Ekstra Internasional Lainnya',
  );

  static const values = [
    A,
    B,
    C,
    D,
    E,
    F,
    G,
    H,
    I,
    J,
    K,
    L,
    M,
    N,
    O,
    P,
    Q,
    R,
    S,
    T,
    U,
  ];

  static Sector? fromKey(String key) {
    return values.where((item) => item.key == key).firstOrNull;
  }

  static List<Sector> getSectors() {
    return values;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'key': key, 'text': text};
  }

  /// Parse from JSON (returns null if key not found)
  static Sector? fromJson(Map<String, dynamic> json) {
    return fromKey(json['key']);
  }

  @override
  List<Object?> get props => [key, text];
}

class BuildingStatus extends Equatable {
  final String key;
  final String text;

  const BuildingStatus({required this.key, required this.text});

  const BuildingStatus._(this.key, this.text);

  static const fixed = BuildingStatus._('tetap', 'Tetap');
  static const notFixed = BuildingStatus._('tidak_tetap', 'Tidak Tetap');

  static const values = [fixed, notFixed];

  static BuildingStatus? fromKey(String key) {
    return values.where((item) => item.key == key).firstOrNull;
  }

  static List<BuildingStatus> getStatuses() {
    return values;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'key': key, 'text': text};
  }

  /// Parse from JSON (returns null if key not found)
  static BuildingStatus? fromJson(Map<String, dynamic> json) {
    return fromKey(json['key']);
  }

  @override
  List<Object?> get props => [key, text];
}
