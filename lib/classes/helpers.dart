import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:kendedes_mobile/classes/map_config.dart';
import 'package:latlong2/latlong.dart';

class DateHelper {
  static final DateFormat _formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

  /// Formats [DateTime?] into Laravel-compatible string, or returns null.
  static String? format(DateTime? dateTime) {
    return dateTime == null ? null : _formatter.format(dateTime);
  }
}

class MapHelper {
  static LatLngBounds paddedAreaFromPoint({
    required LatLng center,
    double paddingInMeters = MapConfig.defaultPaddedAreaInMeters,
  }) {
    final Distance distance = Distance();

    final north = distance.offset(center, paddingInMeters, 0); // North
    final south = distance.offset(center, paddingInMeters, 180); // South
    final east = distance.offset(center, paddingInMeters, 90); // East
    final west = distance.offset(center, paddingInMeters, 270); // West

    final southWest = LatLng(south.latitude, west.longitude);
    final northEast = LatLng(north.latitude, east.longitude);

    return LatLngBounds(southWest, northEast);
  }
}
