import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/models/poligon_data.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:latlong2/latlong.dart';

class TaggingState extends Equatable {
  final TaggingStateData data;

  const TaggingState({required this.data});

  @override
  List<Object> get props => [data];
}

class TagSuccess extends TaggingState {
  final TagData newTag;

  const TagSuccess({required this.newTag, required super.data});

  @override
  List<Object> get props => [newTag, data];
}

class TagError extends TaggingState {
  final String errorMessage;

  const TagError({required this.errorMessage, required super.data});

  @override
  List<Object> get props => [errorMessage, data];
}

class TagSelected extends TaggingState {
  const TagSelected({required super.data});

  @override
  List<Object> get props => [data];
}

class MovedCurrentLocation extends TaggingState {
  const MovedCurrentLocation({required super.data});

  @override
  List<Object> get props => [data];
}

class TaggingStateData {
  final List<TagData> tags;
  final List<PoligonData> polygons;
  final LatLng? currentLocation;
  final bool isLoadingTag;
  final bool isLoadingPolygon;
  final bool isLoadingCurrentLocation;
  final double currentZoom;
  final double rotation;
  final List<TagData> selectedTags;

  TaggingStateData({
    required this.tags,
    required this.polygons,
    required this.isLoadingTag,
    required this.isLoadingPolygon,
    required this.isLoadingCurrentLocation,
    this.currentLocation,
    required this.currentZoom,
    required this.rotation,
    required this.selectedTags,
  });

  TaggingStateData copyWith({
    List<TagData>? tags,
    List<PoligonData>? polygons,
    bool? isLoadingTag,
    bool? isLoadingPolygon,
    bool? isLoadingCurrentLocation,
    LatLng? currentLocation,
    double? currentZoom,
    double? rotation,
    List<TagData>? selectedTags,
  }) {
    return TaggingStateData(
      tags: tags ?? this.tags,
      polygons: polygons ?? this.polygons,
      isLoadingTag: isLoadingTag ?? this.isLoadingTag,
      isLoadingPolygon: isLoadingPolygon ?? this.isLoadingPolygon,
      isLoadingCurrentLocation:
          isLoadingCurrentLocation ?? this.isLoadingCurrentLocation,
      currentLocation: currentLocation ?? this.currentLocation,
      currentZoom: currentZoom ?? this.currentZoom,
      rotation: rotation ?? this.rotation,
      selectedTags: selectedTags ?? this.selectedTags,
    );
  }
}
