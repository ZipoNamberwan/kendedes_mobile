import 'package:equatable/equatable.dart';

class Regency extends Equatable {
  final String id;
  final String shortCode;
  final String longCode;
  final String name;

  @override
  List<Object?> get props => [id];

  const Regency({
    required this.id,
    required this.shortCode,
    required this.longCode,
    required this.name,
  });

  factory Regency.fromJson(Map<String, dynamic> json) {
    return Regency(
      id: json['id'] as String,
      shortCode: json['short_code'] as String,
      longCode: json['long_code'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'short_code': shortCode,
      'long_code': longCode,
    };
  }

  /// Returns a list of predefined regencies in East Java
  static List<Regency> getPredefinedRegencies() {
    return [
      Regency(id: '3501', shortCode: '01', longCode: '3501', name: 'PACITAN'),
      Regency(id: '3502', shortCode: '02', longCode: '3502', name: 'PONOROGO'),
      Regency(
        id: '3503',
        shortCode: '03',
        longCode: '3503',
        name: 'TRENGGALEK',
      ),
      Regency(
        id: '3504',
        shortCode: '04',
        longCode: '3504',
        name: 'TULUNGAGUNG',
      ),
      Regency(id: '3505', shortCode: '05', longCode: '3505', name: 'BLITAR'),
      Regency(id: '3506', shortCode: '06', longCode: '3506', name: 'KEDIRI'),
      Regency(id: '3507', shortCode: '07', longCode: '3507', name: 'MALANG'),
      Regency(id: '3508', shortCode: '08', longCode: '3508', name: 'LUMAJANG'),
      Regency(id: '3509', shortCode: '09', longCode: '3509', name: 'JEMBER'),
      Regency(
        id: '3510',
        shortCode: '10',
        longCode: '3510',
        name: 'BANYUWANGI',
      ),
      Regency(id: '3511', shortCode: '11', longCode: '3511', name: 'BONDOWOSO'),
      Regency(id: '3512', shortCode: '12', longCode: '3512', name: 'SITUBONDO'),
      Regency(
        id: '3513',
        shortCode: '13',
        longCode: '3513',
        name: 'PROBOLINGGO',
      ),
      Regency(id: '3514', shortCode: '14', longCode: '3514', name: 'PASURUAN'),
      Regency(id: '3515', shortCode: '15', longCode: '3515', name: 'SIDOARJO'),
      Regency(id: '3516', shortCode: '16', longCode: '3516', name: 'MOJOKERTO'),
      Regency(id: '3517', shortCode: '17', longCode: '3517', name: 'JOMBANG'),
      Regency(id: '3518', shortCode: '18', longCode: '3518', name: 'NGANJUK'),
      Regency(id: '3519', shortCode: '19', longCode: '3519', name: 'MADIUN'),
      Regency(id: '3520', shortCode: '20', longCode: '3520', name: 'MAGETAN'),
      Regency(id: '3521', shortCode: '21', longCode: '3521', name: 'NGAWI'),
      Regency(
        id: '3522',
        shortCode: '22',
        longCode: '3522',
        name: 'BOJONEGORO',
      ),
      Regency(id: '3523', shortCode: '23', longCode: '3523', name: 'TUBAN'),
      Regency(id: '3524', shortCode: '24', longCode: '3524', name: 'LAMONGAN'),
      Regency(id: '3525', shortCode: '25', longCode: '3525', name: 'GRESIK'),
      Regency(id: '3526', shortCode: '26', longCode: '3526', name: 'BANGKALAN'),
      Regency(id: '3527', shortCode: '27', longCode: '3527', name: 'SAMPANG'),
      Regency(id: '3528', shortCode: '28', longCode: '3528', name: 'PAMEKASAN'),
      Regency(id: '3529', shortCode: '29', longCode: '3529', name: 'SUMENEP'),
      Regency(id: '3571', shortCode: '71', longCode: '3571', name: 'KEDIRI'),
      Regency(id: '3572', shortCode: '72', longCode: '3572', name: 'BLITAR'),
      Regency(id: '3573', shortCode: '73', longCode: '3573', name: 'MALANG'),
      Regency(
        id: '3574',
        shortCode: '74',
        longCode: '3574',
        name: 'PROBOLINGGO',
      ),
      Regency(id: '3575', shortCode: '75', longCode: '3575', name: 'PASURUAN'),
      Regency(id: '3576', shortCode: '76', longCode: '3576', name: 'MOJOKERTO'),
      Regency(id: '3577', shortCode: '77', longCode: '3577', name: 'MADIUN'),
      Regency(id: '3578', shortCode: '78', longCode: '3578', name: 'SURABAYA'),
      Regency(id: '3579', shortCode: '79', longCode: '3579', name: 'BATU'),
    ];
  }
}
