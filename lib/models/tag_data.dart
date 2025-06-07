import 'package:equatable/equatable.dart';
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
  final Project project;

  // Attributes for the supplement tag data
  final String businessName;
  final String? businessOwner;
  final String? businessAddress;
  final BuildingStatus buildingStatus;
  final String description;
  final Sector sector;
  final String? note;

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
}

enum TagType { auto, manual, move }

class Sector extends Equatable {
  final String key;
  final String text;

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
