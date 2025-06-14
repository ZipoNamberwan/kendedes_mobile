import 'package:flutter/material.dart';

class MapType {
  final String key;
  final String name;
  final String url;
  final String? attribution;
  final IconData? icon;

  MapType({
    required this.key,
    required this.name,
    required this.url,
    this.attribution,
    this.icon,
  });

  const MapType._(this.key, this.name, this.url, this.attribution, this.icon);

  static const googleSatelite = MapType._(
    'google_satelite',
    'Google Satellite',
    'https://www.google.com/maps/vt?lyrs=s@189&gl=cn&x={x}&y={y}&z={z}',
    'Google Maps',
    Icons.satellite_alt_rounded,
  );
  static const openStreetMapDefault = MapType._(
    'openstreetmap_default',
    'OpenStreetMap',
    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    'OpenStreetMap',
    Icons.map,
  );

  static const values = [googleSatelite, openStreetMapDefault];

  static MapType? fromKey(String key) {
    return values.where((item) => item.key == key).firstOrNull;
  }

  static List<MapType> getMapTypes() {
    return values;
  }
}
