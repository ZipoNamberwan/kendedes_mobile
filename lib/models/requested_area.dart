import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RequestedArea {
  final LatLngBounds bounds;

  RequestedArea({required LatLng northeast, required LatLng southwest})
    : bounds = LatLngBounds(northeast, southwest);

  /// Optional: Check if another bounds is fully inside this area
  bool containsBounds(LatLngBounds otherBounds) {
    return bounds.contains(otherBounds.northEast) &&
        bounds.contains(otherBounds.southWest);
  }
}
