import 'package:latlong2/latlong.dart';

class PoligonData {
  final String id;
  final String polygonType;
  final List<LatLng> points;

  PoligonData({
    required this.id,
    required this.polygonType,
    required this.points,
  });
}
