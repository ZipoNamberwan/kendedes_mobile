import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/models/area/regency.dart';
import 'package:kendedes_mobile/models/area/subdistrict.dart';
import 'package:kendedes_mobile/models/area/village.dart';
import 'package:kendedes_mobile/models/polygon.dart';
import 'package:latlong2/latlong.dart';

class Sls extends Equatable {
  final String id;
  final String shortCode;
  final String longCode;
  final String name;
  final String villageId;
  final Polygon? polygon;
  final Village? village;

  @override
  List<Object?> get props => [id];

  const Sls({
    required this.id,
    required this.shortCode,
    required this.longCode,
    required this.name,
    required this.villageId,
    this.polygon,
    this.village,
  });

  factory Sls.fromJson(Map<String, dynamic> json) {
    return Sls(
      id: json['id'].toString(),
      shortCode: json['short_code'] as String,
      longCode: json['long_code'] as String,
      name: json['name'] as String,
      villageId: json['village_id'] as String,
      village:
          json['village'] != null ? Village.fromJson(json['village']) : null,
      polygon:
          json['geojson'] != null
              ? Polygon(
                id: json['id'].toString(),
                fullName: json['name'] as String,
                shortName: json['name'] as String,
                longCode: json['long_code'] as String,
                shortCode: json['short_code'] as String,
                type: PolygonType.sls,
                points:
                    (json['geojson']['coordinates'][0][0] as List)
                        .map((point) => LatLng(point[1], point[0]))
                        .toList(),
              )
              : null,
    );
  }

  factory Sls.fromSameLevelServerJson(
    Map<String, dynamic> slsJson,
    Map<String, dynamic> villageJson,
    Map<String, dynamic> subdistrictJson,
    Map<String, dynamic> regencyJson,
  ) {
    try {
      return Sls(
        id: slsJson['id'].toString(),
        shortCode: slsJson['short_code'] as String,
        longCode: slsJson['long_code'] as String,
        name: slsJson['name'] as String,
        villageId: slsJson['village_id'] as String,
        village: Village(
          id: villageJson['id'].toString(),
          shortCode: villageJson['short_code'] as String,
          longCode: villageJson['long_code'] as String,
          name: villageJson['name'] as String,
          subdistrictId: villageJson['subdistrict_id'] as String,
          subdistrict: Subdistrict(
            id: subdistrictJson['id'].toString(),
            shortCode: subdistrictJson['short_code'] as String,
            longCode: subdistrictJson['long_code'] as String,
            name: subdistrictJson['name'] as String,
            regencyId: subdistrictJson['regency_id'] as String,
            regency: Regency(
              id: regencyJson['id'].toString(),
              shortCode: regencyJson['short_code'] as String,
              longCode: regencyJson['long_code'] as String,
              name: regencyJson['name'] as String,
            ),
          ),
        ),
      );
    } catch (e) {
      throw FormatException('Failed to parse Sls from same-level JSON: $e');
    }
  }

  static Sls? fromLocalDbJson(Map<String, dynamic> json) {
    if (json['sls_id'] == null) return null;

    return Sls(
      id: json['sls_id'],
      shortCode: json['sls_short_code'],
      longCode: json['sls_long_code'],
      name: json['sls_name'],
      villageId: json['village_id'],
      village: Village(
        id: json['village_id'],
        shortCode: json['village_short_code'],
        longCode: json['village_long_code'],
        name: json['village_name'],
        subdistrictId: json['subdistrict_id'],
        subdistrict: Subdistrict(
          id: json['subdistrict_id'],
          shortCode: json['subdistrict_short_code'],
          longCode: json['subdistrict_long_code'],
          name: json['subdistrict_name'],
          regencyId: json['regency_id'],
          regency: Regency(
            id: json['regency_id'],
            shortCode: json['regency_short_code'],
            longCode: json['regency_long_code'],
            name: json['regency_name'],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'short_code': shortCode,
      'long_code': longCode,
      'name': name,
      'village_id': villageId,
    };
  }
}
