import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/classes/map_config.dart';
import 'package:kendedes_mobile/models/label_type.dart';
import 'package:kendedes_mobile/models/map_type.dart';
import 'package:kendedes_mobile/models/poligon_data.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/models/requested_area.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:kendedes_mobile/models/user.dart';
import 'package:latlong2/latlong.dart';

class TaggingState extends Equatable {
  final TaggingStateData data;

  const TaggingState({required this.data});

  @override
  List<Object> get props => [data];
}

class InitializingStarted extends TaggingState {
  InitializingStarted()
    : super(
        data: TaggingStateData(
          project: Project(
            id: '',
            name: '',
            description: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            type: ProjectType.supplementMobile,
          ),
          tags: [],
          polygons: [],
          isLoadingTag: false,
          isLoadingPolygon: false,
          isLoadingCurrentLocation: false,
          currentZoom: MapConfig.initialZoom,
          rotation: 0.0,
          selectedTags: [],
          isMultiSelectMode: false,
          isSideBarOpen: false,
          isSubmitting: false,
          filteredTags: [],
          isTaggingInsideBoundsError: false,
          isTaggingInsideBoundsLoading: false,
          isFirstTimeMapLoading: true,
          currentLocation: null,
          currentUser: null,
          isDeletingTag: false,
          isUploadingMultipleTags: false,
          isFilterCurrentProject: false,
          isFilterSentToServer: false,
          requestedAreas: [],
        ),
      );

  @override
  List<Object> get props => [data];
}

class InitializingError extends TaggingState {
  final String errorMessage;
  const InitializingError({required this.errorMessage, required super.data});

  @override
  List<Object> get props => [data, errorMessage];
}

class InitializingSuccess extends TaggingState {
  const InitializingSuccess({required super.data});

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

class TagDeletedLoading extends TaggingState {
  const TagDeletedLoading({required super.data});

  @override
  List<Object> get props => [data];
}

class TagDeletedSuccess extends TaggingState {
  final String successMessage;
  const TagDeletedSuccess({required this.successMessage, required super.data});

  @override
  List<Object> get props => [successMessage, data];
}

class TagDeletedError extends TaggingState {
  final String errorMessage;
  const TagDeletedError({required this.errorMessage, required super.data});

  @override
  List<Object> get props => [errorMessage, data];
}

class MovedCurrentLocation extends TaggingState {
  const MovedCurrentLocation({required super.data});

  @override
  List<Object> get props => [data];
}

class RecordedLocation extends TaggingState {
  final LatLng recordedLocation;
  const RecordedLocation({required this.recordedLocation, required super.data});

  @override
  List<Object> get props => [data];
}

class EditFormShown extends TaggingState {
  const EditFormShown({required super.data});

  @override
  List<Object> get props => [data];
}

class SaveFormSuccess extends TaggingState {
  final TagData newTag;
  final String successMessage;
  const SaveFormSuccess({
    required this.newTag,
    required this.successMessage,
    required super.data,
  });

  @override
  List<Object> get props => [newTag, successMessage, data];
}

class SaveFormError extends TaggingState {
  final String errorMessage;
  const SaveFormError({required this.errorMessage, required super.data});

  @override
  List<Object> get props => [errorMessage, data];
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

class TaggingInsideBoundsFailed extends TaggingState {
  final String errorMessage;
  const TaggingInsideBoundsFailed({
    required this.errorMessage,
    required super.data,
  });

  @override
  List<Object> get props => [data, errorMessage];
}

class TokenExpired extends TaggingState {
  const TokenExpired({required super.data});

  @override
  List<Object> get props => [data];
}

class ZoomLevelNotification extends TaggingState {
  final String message;
  const ZoomLevelNotification({required this.message, required super.data});

  @override
  List<Object> get props => [message, data];
}

class UploadMultipleTagsLoading extends TaggingState {
  const UploadMultipleTagsLoading({required super.data});

  @override
  List<Object> get props => [data];
}

class UploadMultipleTagsError extends TaggingState {
  final String errorMessage;
  const UploadMultipleTagsError({
    required this.errorMessage,
    required super.data,
  });

  @override
  List<Object> get props => [errorMessage, data];
}

class UploadMultipleTagsSuccess extends TaggingState {
  final String successMessage;
  const UploadMultipleTagsSuccess({
    required this.successMessage,
    required super.data,
  });

  @override
  List<Object> get props => [successMessage, data];
}

class DeleteMultipleTagsLoading extends TaggingState {
  const DeleteMultipleTagsLoading({required super.data});

  @override
  List<Object> get props => [data];
}

class DeleteMultipleTagsError extends TaggingState {
  final String errorMessage;
  const DeleteMultipleTagsError({
    required this.errorMessage,
    required super.data,
  });

  @override
  List<Object> get props => [errorMessage, data];
}

class DeleteMultipleTagsSuccess extends TaggingState {
  final String successMessage;
  const DeleteMultipleTagsSuccess({
    required this.successMessage,
    required super.data,
  });

  @override
  List<Object> get props => [successMessage, data];
}

class MockupLocationDetected extends TaggingState {
  const MockupLocationDetected({required super.data});

  @override
  List<Object> get props => [data];
}

class AreaNotRequestedNotification extends TaggingState {
  final LatLng recordedLocation;
  const AreaNotRequestedNotification({
    required this.recordedLocation,
    required super.data,
  });

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
  final LatLng? northEastCorner;
  final LatLng? southWestCorner;
  final List<RequestedArea> requestedAreas;

  // UI attributes
  final bool isMultiSelectMode;
  final bool isSideBarOpen;
  final LabelType? selectedLabelType;
  final MapType? selectedMapType;
  final bool isTaggingInsideBoundsLoading;
  final bool isTaggingInsideBoundsError;
  final bool isFirstTimeMapLoading;

  //filter attribute
  final List<TagData> filteredTags;
  final String? searchQuery;
  final Sector? selectedSectorFilter;
  final ProjectType? selectedProjectTypeFilter;
  final bool isFilterCurrentProject;
  final bool isFilterSentToServer;

  //form attribute
  final bool isSubmitting;
  final Map<String, TaggingFormFieldState<dynamic>> formFields;

  //User attribute
  final User? currentUser;

  //Confirmation dialog attribute
  final bool isDeletingTag;
  final bool isUploadingMultipleTags;

  TaggingStateData({
    required this.project,
    required this.tags,
    required this.polygons,
    required this.isLoadingTag,
    required this.isLoadingPolygon,
    required this.isLoadingCurrentLocation,
    this.currentLocation,
    required this.currentZoom,
    this.northEastCorner,
    this.southWestCorner,
    required this.requestedAreas,
    required this.rotation,
    required this.selectedTags,
    required this.isMultiSelectMode,
    required this.isSideBarOpen,
    required this.isTaggingInsideBoundsLoading,
    required this.isTaggingInsideBoundsError,
    required this.isFirstTimeMapLoading,

    required this.filteredTags,
    this.searchQuery,
    this.selectedSectorFilter,
    this.selectedProjectTypeFilter,
    required this.isFilterCurrentProject,
    required this.isFilterSentToServer,
    this.selectedLabelType,
    this.selectedMapType,
    required this.isSubmitting,
    this.currentUser,
    Map<String, TaggingFormFieldState<dynamic>>? formFields,
    required this.isDeletingTag,
    required this.isUploadingMultipleTags,
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
    formFields['positionLat'] = TaggingFormFieldState<double>();
    formFields['positionLng'] = TaggingFormFieldState<double>();

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
    LatLng? northEastCorner,
    LatLng? southWestCorner,
    List<RequestedArea>? requestedAreas,
    double? currentZoom,
    double? rotation,
    List<TagData>? selectedTags,
    bool? isMultiSelectMode,
    bool? isSideBarOpen,
    bool? isTaggingInsideBoundsLoading,
    bool? isTaggingInsideBoundsError,
    bool? isFirstTimeMapLoading,

    bool? isSubmitting,
    Map<String, TaggingFormFieldState<dynamic>>? formFields,
    bool? isDeletingTag,
    bool? isUploadingMultipleTags,
    bool? resetForm,
    List<TagData>? filteredTags,
    String? searchQuery,
    Sector? selectedSectorFilter,
    ProjectType? selectedProjectTypeFilter,
    bool? resetAllFilter,
    bool? resetSearchQuery,
    bool? resetSectorFilter,
    bool? resetProjectTypeFilter,
    bool? isFilterCurrentProject,
    bool? isFilterSentToServer,
    LabelType? selectedLabelType,
    MapType? selectedMapType,
    User? currentUser,
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
      isFirstTimeMapLoading:
          isFirstTimeMapLoading ?? this.isFirstTimeMapLoading,

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
      selectedMapType: selectedMapType ?? this.selectedMapType,
      northEastCorner: northEastCorner ?? this.northEastCorner,
      southWestCorner: southWestCorner ?? this.southWestCorner,
      isTaggingInsideBoundsLoading:
          isTaggingInsideBoundsLoading ?? this.isTaggingInsideBoundsLoading,
      isTaggingInsideBoundsError:
          isTaggingInsideBoundsError ?? this.isTaggingInsideBoundsError,
      currentUser: currentUser ?? this.currentUser,
      isDeletingTag: isDeletingTag ?? this.isDeletingTag,
      isUploadingMultipleTags:
          isUploadingMultipleTags ?? this.isUploadingMultipleTags,
      isFilterCurrentProject:
          resetAllFilter ?? false
              ? false
              : isFilterCurrentProject ?? this.isFilterCurrentProject,
      isFilterSentToServer:
          resetAllFilter ?? false
              ? false
              : isFilterSentToServer ?? this.isFilterSentToServer,
      requestedAreas: requestedAreas ?? this.requestedAreas,
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
