import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/models/area/subdistrict.dart';
import 'package:kendedes_mobile/models/polygon.dart';
import 'package:latlong2/latlong.dart';

class Village extends Equatable {
  final String id;
  final String shortCode;
  final String longCode;
  final String name;
  final String subdistrictId;
  final Polygon? polygon;
  final Subdistrict? subdistrict;

  @override
  List<Object?> get props => [id];

  const Village({
    required this.id,
    required this.shortCode,
    required this.longCode,
    required this.name,
    required this.subdistrictId,
    this.polygon,
    this.subdistrict,
  });

  factory Village.fromJson(Map<String, dynamic> json) {
    return Village(
      id: json['id'].toString(),
      shortCode: json['short_code'] as String,
      longCode: json['long_code'] as String,
      name: json['name'] as String,
      subdistrictId: json['subdistrict_id'] as String,
      subdistrict:
          json['subdistrict'] != null
              ? Subdistrict.fromJson(json['subdistrict'])
              : null,
      polygon:
          json['geojson'] != null
              ? Polygon(
                id: json['id'].toString(),
                fullName: json['name'] as String,
                shortName: json['name'] as String,
                longCode: json['long_code'] as String,
                shortCode: json['short_code'] as String,
                type: PolygonType.village,
                points:
                    (json['geojson']['coordinates'][0][0] as List)
                        .map((point) => LatLng(point[1], point[0]))
                        .toList(),
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'short_code': shortCode,
      'long_code': longCode,
      'name': name,
      'subdistrict_id': subdistrictId,
    };
  }
}
