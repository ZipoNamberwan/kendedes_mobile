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
  final Project? project;

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
    this.project,

    // Supplement tag data
    required this.businessName,
    this.businessOwner,
    this.businessAddress,
    required this.buildingStatus,
    required this.description,
    required this.sector,
    this.note,
  });
}

enum TagType { auto, manual, move }

class Sector extends Equatable {
  final String label;
  final String text;

  const Sector({required this.label, required this.text});

  static List<Sector> getSectors() {
    return [
      Sector(label: 'A', text: 'A. Pertanian, Kehutanan dan Perikanan'),
      Sector(label: 'B', text: 'B. Pertambangan dan Penggalian'),
      Sector(label: 'C', text: 'C. Industri Pengolahan'),
      Sector(label: 'D', text: 'D. Pengadaan Listrik, Gas, Uap/Air Panas Dan Udara Dingin'),
      Sector(label: 'E', text: 'E. Treatment Air, Treatment Air Limbah, Treatment dan Pemulihan Material Sampah, dan Aktivitas Remediasi'),
      Sector(label: 'F', text: 'F. Konstruksi'),
      Sector(label: 'G', text: 'G. Perdagangan Besar Dan Eceran, Reparasi Dan Perawatan Mobil Dan Sepeda Motor'),
      Sector(label: 'H', text: 'H. Pengangkutan dan Pergudangan'),
      Sector(label: 'I', text: 'I. Penyediaan Akomodasi Dan Penyediaan Makan Minum'),
      Sector(label: 'J', text: 'J. Informasi Dan Komunikasi'),
      Sector(label: 'K', text: 'K. Aktivitas Keuangan dan Asuransi'),
      Sector(label: 'L', text: 'L. Real Estat'),
      Sector(label: 'M', text: 'M. Aktivitas Profesional, Ilmiah Dan Teknis'),
      Sector(label: 'N', text: 'N. Aktivitas Penyewaan dan Sewa Guna Usaha Tanpa Hak Opsi, Ketenagakerjaan, Agen Perjalanan dan Penunjang Usaha Lainnya'),
      Sector(label: 'O', text: 'O. Administrasi Pemerintahan, Pertahanan Dan Jaminan Sosial Wajib'),
      Sector(label: 'P', text: 'P. Pendidikan'),
      Sector(label: 'Q', text: 'Q. Aktivitas Kesehatan Manusia Dan Aktivitas Sosial'),
      Sector(label: 'R', text: 'R. Kesenian, Hiburan Dan Rekreasi'),
      Sector(label: 'S', text: 'S. Aktivitas Jasa Lainnya'),
      Sector(label: 'T', text: 'T. Aktivitas Rumah Tangga Sebagai Pemberi Kerja; Aktivitas Yang Menghasilkan Barang Dan Jasa Oleh Rumah Tangga yang Digunakan untuk Memenuhi Kebutuhan Sendiri'),
      Sector(label: 'U', text: 'U. Aktivitas Badan Internasional Dan Badan Ekstra Internasional Lainnya'),
    ];
  }

  @override
  List<Object?> get props => [label, text];
}

class BuildingStatus extends Equatable {
  final String label;
  final String text;

  const BuildingStatus({required this.label, required this.text});

  static List<BuildingStatus> getStatuses() {
    return [
      BuildingStatus(label: 'tetap', text: 'Tetap'),
      BuildingStatus(label: 'tidak tetap', text: 'Tidak Tetap'),
    ];
  }

  @override
  List<Object?> get props => [label, text];
}
