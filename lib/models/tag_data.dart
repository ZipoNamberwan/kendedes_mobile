import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/models/user.dart';

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

  // Attributes for the supplement tag data
  final String businessName;
  final String? businessOwner;
  final String? businessAddress;
  final BuildingStatus buildingStatus;
  final String description;
  final Sector sector;
  final String? note;
  final User user;

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

    // Supplement tag data
    required this.businessName,
    this.businessOwner,
    this.businessAddress,
    required this.buildingStatus,
    required this.description,
    required this.sector,
    this.note,
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
        return sector.key;
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
    } else if (project.type.key == ProjectType.supplementMobile.key) {
      if (currentProjectId == project.id) {
        return Colors.deepOrange;
      } else if (currentUserId == user.id) {
        return Colors.amber;
      }

      return Colors.cyan;
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
      return true;
    }
    return false;
  }

  bool showCloudIcon(String currentProjectId) {
    if (currentProjectId == project.id) {
      return true;
    }
    return false;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': positionLat,
      'longitude': positionLng,
      'name': businessName,
      'owner': businessOwner,
      'address': businessAddress,
      'building': buildingStatus.text,
      'description': description,
      'sector': sector.text,
      'note': note,
      'project': {
        'id': project.id,
        'name': project.name,
        'description': project.description,
      },
      'user': user.id,
      'organization': user.organization?.id,
    };
  }

  /// Parse from JSON
  factory TagData.fromJson(Map<String, dynamic> json) {
    try {
      return TagData(
        id: json['id'] as String,
        positionLat: double.tryParse(json['latitude'].toString()) ?? 0.0,
        positionLng: double.tryParse(json['longitude'].toString()) ?? 0.0,
        hasChanged: false,
        hasSentToServer: true,
        type: TagType.auto,
        initialPositionLat: double.tryParse(json['latitude'].toString()) ?? 0.0,
        initialPositionLng:
            double.tryParse(json['longitude'].toString()) ?? 0.0,
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
        project: Project.fromJson(json['project'] as Map<String, dynamic>),
        businessName: json['name'] as String,
        businessOwner: json['owner'] as String?,
        businessAddress: json['address'] as String?,
        buildingStatus:
            BuildingStatus.fromKey(json['status']) ?? BuildingStatus.fixed,
        description: json['description'] as String,
        sector:
            Sector.fromKey((json['sector'] as String)[0].toUpperCase()) ??
            Sector.G,
        note: json['note'] as String?,
        user: User.fromJson(json['user'] as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Failed to parse TagData: $e');
    }
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

enum TagType {
  auto,
  manual,
  move,
}

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
