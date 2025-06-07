import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/models/poligon_data.dart';
import 'package:kendedes_mobile/models/project.dart';
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

class TagDeleted extends TaggingState {
  const TagDeleted({required super.data});

  @override
  List<Object> get props => [data];
}

class MovedCurrentLocation extends TaggingState {
  const MovedCurrentLocation({required super.data});

  @override
  List<Object> get props => [data];
}

class RecordedLocation extends TaggingState {
  const RecordedLocation({required super.data});

  @override
  List<Object> get props => [data];
}

class EditFormShown extends TaggingState {
  const EditFormShown({required super.data});

  @override
  List<Object> get props => [data];
}

class SideBarOpened extends TaggingState {
  const SideBarOpened({required super.data});

  @override
  List<Object> get props => [data];
}

class SideBarClosed extends TaggingState {
  const SideBarClosed({required super.data});

  @override
  List<Object> get props => [data];
}

class SearchQueryCleared extends TaggingState {
  const SearchQueryCleared({required super.data});

  @override
  List<Object> get props => [data];
}

class AllFilterCleared extends TaggingState {
  const AllFilterCleared({required super.data});

  @override
  List<Object> get props => [data];
}

class TaggingStateData {
  final Project project;
  final List<TagData> tags;
  final List<PoligonData> polygons;
  final bool isLoadingTag;
  final bool isLoadingPolygon;
  final bool isLoadingCurrentLocation;
  final List<TagData> selectedTags;

  // Map attributes
  final double currentZoom;
  final double rotation;
  final LatLng? currentLocation;

  // UI attributes
  final bool isMultiSelectMode;
  final bool isSideBarOpen;
  final String? selectedLabelType;

  //filter attribute
  final List<TagData> filteredTags;
  final String? searchQuery;
  final Sector? selectedSectorFilter;
  final ProjectType? selectedProjectTypeFilter;

  //form attribute
  final bool isSubmitting;
  final Map<String, TaggingFormFieldState<dynamic>> formFields;

  TaggingStateData({
    required this.project,
    required this.tags,
    required this.polygons,
    required this.isLoadingTag,
    required this.isLoadingPolygon,
    required this.isLoadingCurrentLocation,
    this.currentLocation,
    required this.currentZoom,
    required this.rotation,
    required this.selectedTags,
    required this.isMultiSelectMode,
    required this.isSideBarOpen,

    required this.filteredTags,
    this.searchQuery,
    this.selectedSectorFilter,
    this.selectedProjectTypeFilter,
    this.selectedLabelType,
    required this.isSubmitting,
    Map<String, TaggingFormFieldState<dynamic>>? formFields,
  }) : formFields = formFields ?? _generateFormFields();

  static Map<String, TaggingFormFieldState<dynamic>> _generateFormFields() {
    final formFields = <String, TaggingFormFieldState<dynamic>>{};

    formFields['id'] = TaggingFormFieldState<String?>();
    formFields['name'] = TaggingFormFieldState<String>();
    formFields['owner'] = TaggingFormFieldState<String?>();
    formFields['address'] = TaggingFormFieldState<String?>();
    formFields['building'] = TaggingFormFieldState<BuildingStatus>();
    formFields['description'] = TaggingFormFieldState<String>();
    formFields['sector'] = TaggingFormFieldState<Sector>();
    formFields['note'] = TaggingFormFieldState<String?>();
    formFields['position'] = TaggingFormFieldState<LatLng>();

    return formFields;
  }

  TaggingStateData copyWith({
    Project? project,
    List<TagData>? tags,
    List<PoligonData>? polygons,
    bool? isLoadingTag,
    bool? isLoadingPolygon,
    bool? isLoadingCurrentLocation,
    LatLng? currentLocation,
    double? currentZoom,
    double? rotation,
    List<TagData>? selectedTags,
    bool? isMultiSelectMode,
    bool? isSideBarOpen,

    bool? isSubmitting,
    Map<String, TaggingFormFieldState<dynamic>>? formFields,
    bool? resetForm,
    List<TagData>? filteredTags,
    String? searchQuery,
    Sector? selectedSectorFilter,
    ProjectType? selectedProjectTypeFilter,
    bool? resetAllFilter,
    bool? resetSearchQuery,
    bool? resetSectorFilter,
    bool? resetProjectTypeFilter,
    String? selectedLabelType,
  }) {
    return TaggingStateData(
      project: project ?? this.project,
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
      isMultiSelectMode: isMultiSelectMode ?? this.isMultiSelectMode,
      isSideBarOpen: isSideBarOpen ?? this.isSideBarOpen,

      filteredTags: filteredTags ?? this.filteredTags,
      searchQuery:
          resetAllFilter ?? false
              ? null
              : resetSearchQuery ?? false
              ? null
              : searchQuery ?? this.searchQuery,
      selectedSectorFilter:
          resetAllFilter ?? false
              ? null
              : resetSectorFilter ?? false
              ? null
              : selectedSectorFilter ?? this.selectedSectorFilter,
      selectedProjectTypeFilter:
          resetAllFilter ?? false
              ? null
              : resetProjectTypeFilter ?? false
              ? null
              : selectedProjectTypeFilter ?? this.selectedProjectTypeFilter,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      formFields:
          (resetForm ?? false)
              ? _generateFormFields()
              : formFields ?? this.formFields,
      selectedLabelType: selectedLabelType ?? this.selectedLabelType,
    );
  }
}

class TaggingFormFieldState<T> {
  final T? value;
  final String? error;

  TaggingFormFieldState({this.value, this.error});

  TaggingFormFieldState<T> copyWith({T? value, String? error}) {
    return TaggingFormFieldState<T>(value: value ?? this.value, error: error);
  }

  TaggingFormFieldState<T> clearError() => copyWith(error: null);
}
