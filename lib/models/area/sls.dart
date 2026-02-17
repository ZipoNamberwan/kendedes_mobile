import 'package:equatable/equatable.dart';
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
                type: PolygonType.sls,
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
      'village_id': villageId,
    };
  }
}
