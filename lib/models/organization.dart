class Organization {
  final String id;
  final String shortCode;
  final String longCode;
  final String name;

  Organization({
    required this.id,
    required this.name,
    required this.shortCode,
    required this.longCode,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'].toString(),
      name: json['name'] as String,
      shortCode: json['short_code'] as String,
      longCode: json['long_code'] as String,
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

  // write static method to return specific organization by id from staticOrganizations list
  static Organization? getById(String id) {
    try {
      return staticOrganizations.firstWhere((org) => org.id == id);
    } catch (e) {
      return null;
    }
  }

  static final List<Organization> staticOrganizations = [
    Organization(
      id: '3500',
      shortCode: '3500',
      longCode: '3500',
      name: 'BPS PROVINSI JAWA TIMUR',
    ),
    Organization(
      id: '3501',
      shortCode: '3501',
      longCode: '3501',
      name: 'BPS KABUPATEN PACITAN',
    ),
    Organization(
      id: '3502',
      shortCode: '3502',
      longCode: '3502',
      name: 'BPS KABUPATEN PONOROGO',
    ),
    Organization(
      id: '3503',
      shortCode: '3503',
      longCode: '3503',
      name: 'BPS KABUPATEN TRENGGALEK',
    ),
    Organization(
      id: '3504',
      shortCode: '3504',
      longCode: '3504',
      name: 'BPS KABUPATEN TULUNGAGUNG',
    ),
    Organization(
      id: '3505',
      shortCode: '3505',
      longCode: '3505',
      name: 'BPS KABUPATEN BLITAR',
    ),
    Organization(
      id: '3506',
      shortCode: '3506',
      longCode: '3506',
      name: 'BPS KABUPATEN KEDIRI',
    ),
    Organization(
      id: '3507',
      shortCode: '3507',
      longCode: '3507',
      name: 'BPS KABUPATEN MALANG',
    ),
    Organization(
      id: '3508',
      shortCode: '3508',
      longCode: '3508',
      name: 'BPS KABUPATEN LUMAJANG',
    ),
    Organization(
      id: '3509',
      shortCode: '3509',
      longCode: '3509',
      name: 'BPS KABUPATEN JEMBER',
    ),
    Organization(
      id: '3510',
      shortCode: '3510',
      longCode: '3510',
      name: 'BPS KABUPATEN BANYUWANGI',
    ),
    Organization(
      id: '3511',
      shortCode: '3511',
      longCode: '3511',
      name: 'BPS KABUPATEN BONDOWOSO',
    ),
    Organization(
      id: '3512',
      shortCode: '3512',
      longCode: '3512',
      name: 'BPS KABUPATEN SITUBONDO',
    ),
    Organization(
      id: '3513',
      shortCode: '3513',
      longCode: '3513',
      name: 'BPS KABUPATEN PROBOLINGGO',
    ),
    Organization(
      id: '3514',
      shortCode: '3514',
      longCode: '3514',
      name: 'BPS KABUPATEN PASURUAN',
    ),
    Organization(
      id: '3515',
      shortCode: '3515',
      longCode: '3515',
      name: 'BPS KABUPATEN SIDOARJO',
    ),
    Organization(
      id: '3516',
      shortCode: '3516',
      longCode: '3516',
      name: 'BPS KABUPATEN MOJOKERTO',
    ),
    Organization(
      id: '3517',
      shortCode: '3517',
      longCode: '3517',
      name: 'BPS KABUPATEN JOMBANG',
    ),
    Organization(
      id: '3518',
      shortCode: '3518',
      longCode: '3518',
      name: 'BPS KABUPATEN NGANJUK',
    ),
    Organization(
      id: '3519',
      shortCode: '3519',
      longCode: '3519',
      name: 'BPS KABUPATEN MADIUN',
    ),
    Organization(
      id: '3520',
      shortCode: '3520',
      longCode: '3520',
      name: 'BPS KABUPATEN MAGETAN',
    ),
    Organization(
      id: '3521',
      shortCode: '3521',
      longCode: '3521',
      name: 'BPS KABUPATEN NGAWI',
    ),
    Organization(
      id: '3522',
      shortCode: '3522',
      longCode: '3522',
      name: 'BPS KABUPATEN BOJONEGORO',
    ),
    Organization(
      id: '3523',
      shortCode: '3523',
      longCode: '3523',
      name: 'BPS KABUPATEN TUBAN',
    ),
    Organization(
      id: '3524',
      shortCode: '3524',
      longCode: '3524',
      name: 'BPS KABUPATEN LAMONGAN',
    ),
    Organization(
      id: '3525',
      shortCode: '3525',
      longCode: '3525',
      name: 'BPS KABUPATEN GRESIK',
    ),
    Organization(
      id: '3526',
      shortCode: '3526',
      longCode: '3526',
      name: 'BPS KABUPATEN BANGKALAN',
    ),
    Organization(
      id: '3527',
      shortCode: '3527',
      longCode: '3527',
      name: 'BPS KABUPATEN SAMPANG',
    ),
    Organization(
      id: '3528',
      shortCode: '3528',
      longCode: '3528',
      name: 'BPS KABUPATEN PAMEKASAN',
    ),
    Organization(
      id: '3529',
      shortCode: '3529',
      longCode: '3529',
      name: 'BPS KABUPATEN SUMENEP',
    ),
    Organization(
      id: '3571',
      shortCode: '3571',
      longCode: '3571',
      name: 'BPS KOTA KEDIRI',
    ),
    Organization(
      id: '3572',
      shortCode: '3572',
      longCode: '3572',
      name: 'BPS KOTA BLITAR',
    ),
    Organization(
      id: '3573',
      shortCode: '3573',
      longCode: '3573',
      name: 'BPS KOTA MALANG',
    ),
    Organization(
      id: '3574',
      shortCode: '3574',
      longCode: '3574',
      name: 'BPS KOTA PROBOLINGGO',
    ),
    Organization(
      id: '3575',
      shortCode: '3575',
      longCode: '3575',
      name: 'BPS KOTA PASURUAN',
    ),
    Organization(
      id: '3576',
      shortCode: '3576',
      longCode: '3576',
      name: 'BPS KOTA MOJOKERTO',
    ),
    Organization(
      id: '3577',
      shortCode: '3577',
      longCode: '3577',
      name: 'BPS KOTA MADIUN',
    ),
    Organization(
      id: '3578',
      shortCode: '3578',
      longCode: '3578',
      name: 'BPS KOTA SURABAYA',
    ),
    Organization(
      id: '3579',
      shortCode: '3579',
      longCode: '3579',
      name: 'BPS KOTA BATU',
    ),
  ];
}
