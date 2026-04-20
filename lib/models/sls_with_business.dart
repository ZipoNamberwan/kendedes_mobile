import 'package:kendedes_mobile/models/area/regency.dart';
import 'package:kendedes_mobile/models/area/sls.dart';
import 'package:kendedes_mobile/models/area/subdistrict.dart';
import 'package:kendedes_mobile/models/area/village.dart';
import 'package:kendedes_mobile/models/polygon.dart';
import 'package:kendedes_mobile/models/user.dart';

class SlsWithBusiness {
  final String id;
  final Sls sls;
  final int businessCount;
  final User user;

  SlsWithBusiness({
    required this.id,
    required this.sls,
    required this.businessCount,
    required this.user,
  });

  /// Convert to database format for sls_with_business table
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sls_id': sls.id,
      'sls_short_code': sls.shortCode,
      'sls_long_code': sls.longCode,
      'sls_name': sls.name,
      'village_id': sls.village?.id,
      'village_short_code': sls.village?.shortCode,
      'village_long_code': sls.village?.longCode,
      'village_name': sls.village?.name,
      'subdistrict_id': sls.village?.subdistrict?.id,
      'subdistrict_short_code': sls.village?.subdistrict?.shortCode,
      'subdistrict_long_code': sls.village?.subdistrict?.longCode,
      'subdistrict_name': sls.village?.subdistrict?.name,
      'regency_id': sls.village?.subdistrict?.regency?.id,
      'regency_short_code': sls.village?.subdistrict?.regency?.shortCode,
      'regency_long_code': sls.village?.subdistrict?.regency?.longCode,
      'regency_name': sls.village?.subdistrict?.regency?.name,

      'business_count': businessCount,
      'user_id': user.id,
    };
  }

  factory SlsWithBusiness.fromJson(
    Map<String, dynamic> json,
    Polygon? polygon,
  ) {
    return SlsWithBusiness(
      id: json['id'] as String,
      sls: Sls(
        id: json['sls_id'] as String,
        name: json['sls_name'] as String,
        shortCode: json['sls_short_code'] as String,
        longCode: json['sls_long_code'] as String,
        villageId: json['village_id'] as String,
        village: Village(
          id: json['village_id'] as String,
          name: json['village_name'] as String,
          shortCode: json['village_short_code'] as String,
          longCode: json['village_long_code'] as String,
          subdistrictId: json['subdistrict_id'] as String,
          subdistrict: Subdistrict(
            id: json['subdistrict_id'] as String,
            name: json['subdistrict_name'] as String,
            shortCode: json['subdistrict_short_code'] as String,
            longCode: json['subdistrict_long_code'] as String,
            regencyId: json['regency_id'] as String,
            regency: Regency(
              id: json['regency_id'] as String,
              name: json['regency_name'] as String,
              shortCode: json['regency_short_code'] as String,
              longCode: json['regency_long_code'] as String,
            ),
          ),
        ),
        polygon: polygon,
      ),
      businessCount: json['business_count'] as int,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
