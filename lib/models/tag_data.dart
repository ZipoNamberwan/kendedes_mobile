import 'package:latlong2/latlong.dart';

class TagData {
  final String id;
  final String? type;
  final LatLng position;

  TagData({required this.id, this.type, required this.position});
}
