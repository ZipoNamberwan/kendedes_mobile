import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';
import 'package:kendedes_mobile/hive/hive_types.dart';
import 'package:kendedes_mobile/models/project.dart';
part 'tag_data.g.dart';

@HiveType(typeId: tagDataTypeId)
class TagData extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final double positionLat;
  @HiveField(2)
  final double positionLng;
  @HiveField(3)
  final bool hasChanged;
  @HiveField(4)
  final bool hasSentToServer;
  @HiveField(5)
  final TagType type;
  @HiveField(6)
  final double initialPositionLat;
  @HiveField(7)
  final double initialPositionLng;
  @HiveField(8)
  final bool isDeleted;
  @HiveField(9)
  final DateTime? createdAt;
  @HiveField(10)
  final DateTime? updatedAt;
  @HiveField(11)
  final DateTime? deletedAt;
  @HiveField(12)
  final int? incrementalId;
  @HiveField(13)
  final Project project;

  // Attributes for the supplement tag data
  @HiveField(14)
  final String businessName;
  @HiveField(15)
  final String? businessOwner;
  @HiveField(16)
  final String? businessAddress;
  @HiveField(17)
  final BuildingStatus buildingStatus;
  @HiveField(18)
  final String description;
  @HiveField(19)
  final Sector sector;
  @HiveField(20)
  final String? note;

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

    // Supplement tag data
    required this.businessName,
    this.businessOwner,
    this.businessAddress,
    required this.buildingStatus,
    required this.description,
    required this.sector,
    this.note,
  });

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

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position_lat': positionLat,
      'position_lng': positionLng,
      'has_changed': hasChanged,
      'has_sent_to_server': hasSentToServer,
      'type': type.name,
      'initial_position_lat': initialPositionLat,
      'initial_position_lng': initialPositionLng,
      'is_deleted': isDeleted,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'incremental_id': incrementalId,
      'project': project.toJson(),
      'business_name': businessName,
      'business_owner': businessOwner,
      'business_address': businessAddress,
      'building_status': buildingStatus.toJson(),
      'description': description,
      'sector': sector.toJson(),
      'note': note,
    };
  }

  /// Parse from JSON
  factory TagData.fromJson(Map<String, dynamic> json) {
    return TagData(
      id: json['id'] as String,
      positionLat: double.tryParse(json['latitude'].toString()) ?? 0.0,
      positionLng: double.tryParse(json['longitude'].toString()) ?? 0.0,
      hasChanged: false,
      hasSentToServer: true,
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

@HiveType(typeId: tagTypeTypeId)
enum TagType {
  @HiveField(0)
  auto,
  @HiveField(1)
  manual,
  @HiveField(2)
  move,
}

@HiveType(typeId: sectorTypeId)
class Sector extends Equatable {
  @HiveField(0)
  final String key;
  @HiveField(1)
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

@HiveType(typeId: buildingStatusTypeId)
class BuildingStatus extends Equatable {
  @HiveField(0)
  final String key;
  @HiveField(1)
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
