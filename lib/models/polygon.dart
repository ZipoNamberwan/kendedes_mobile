import 'package:latlong2/latlong.dart';

class Polygon {
  final String id;
  final String fullName;
  final String shortName;
  final PolygonType type;
  final List<LatLng> points;

  Polygon({
    required this.id,
    required this.fullName,
    required this.shortName,
    required this.type,
    required this.points,
  });

  /// Create a copy of this Polygon with updated values
  Polygon copyWith({
    String? id,
    String? fullName,
    String? shortName,
    PolygonType? type,
    List<LatLng>? points,
  }) {
    return Polygon(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      shortName: shortName ?? this.shortName,
      type: type ?? this.type,
      points: points ?? this.points,
    );
  }

  /// Convert to database format for polygons table
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'full_name': fullName,
      'short_name': shortName,
      'type': type.name,
    };
  }

  /// Convert points to database format for polygon_points table
  List<Map<String, dynamic>> pointsToDbList() {
    return points
        .map(
          (point) => {'latitude': point.latitude, 'longitude': point.longitude},
        )
        .toList();
  }

  /// Create Polygon from database data
  static Polygon fromDbData(
    Map<String, dynamic> polygonData,
    List<Map<String, dynamic>> pointsData,
  ) {
    return Polygon(
      id: polygonData['id'] as String,
      fullName: polygonData['full_name'] as String,
      shortName: polygonData['short_name'] as String,
      type: _parsePolygonType(polygonData['type'] as String),
      points:
          pointsData
              .map(
                (point) => LatLng(
                  point['latitude'] as double,
                  point['longitude'] as double,
                ),
              )
              .toList(),
    );
  }

  /// Parse polygon type from string
  static PolygonType _parsePolygonType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'regency':
        return PolygonType.regency;
      case 'subdistrict':
        return PolygonType.subdistrict;
      case 'village':
        return PolygonType.village;
      case 'sls':
        return PolygonType.sls;
      default:
        throw ArgumentError('Unknown polygon type: $typeString');
    }
  }
}

enum PolygonType { regency, subdistrict, village, sls }
