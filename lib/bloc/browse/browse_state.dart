import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/classes/map_config.dart';
import 'package:kendedes_mobile/models/area/regency.dart';
import 'package:kendedes_mobile/models/area/sls.dart';
import 'package:kendedes_mobile/models/area/subdistrict.dart';
import 'package:kendedes_mobile/models/area/village.dart';
import 'package:kendedes_mobile/models/interaction_mode.dart';
import 'package:kendedes_mobile/models/label_type.dart';
import 'package:kendedes_mobile/models/map_type.dart';
import 'package:kendedes_mobile/models/polygon.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/models/requested_area.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:kendedes_mobile/models/user.dart';
import 'package:latlong2/latlong.dart';

class BrowseState extends Equatable {
  final BrowseStateData data;

  const BrowseState({required this.data});

  @override
  List<Object> get props => [data];
}

class InitializingStarted extends BrowseState {
  InitializingStarted()
    : super(
        data: BrowseStateData(
          currentZoom: MapConfig.initialZoom,
          isDeletingPolygon: false,
          isLoadingCurrentLocation: false,
          isLoadingPolygon: false,
          isLoadingBusiness: false,
          loadMode: BusinessLoadMode.area,
          viewMode: BrowseViewMode.map,
          polygons: [],
          requestedAreas: [],
          rotation: 0,
          selectedBusinesses: [],
          businesses: [],
          filteredBusinesses: [],
          regencies: [],
          subdistricts: [],
          villages: [],
          sls: [],
          isLoadBusinessContainerExpanded: true,
          isBusinessInsideBoundsError: false,
          isBusinessInsideBoundsLoading: false,
          isBusinessBySlsLoading: false,
          isBusinessBySlsError: false,
          isLoadingRegency: false,
          isLoadingSubdistrict: false,
          isLoadingVillage: false,
          isLoadingSls: false,
          isRegencyError: false,
          isSubdistrictError: false,
          isVillageError: false,
          isSlsError: false,
          browseProject: Project(
            id: '',
            name: '',
            description: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            type: ProjectType.supplementMobile,
            interactionMode: InteractionMode.browse,
          ),
        ),
      );

  @override
  List<Object> get props => [data];
}

class InitializingSuccess extends BrowseState {
  const InitializingSuccess({required super.data});

  @override
  List<Object> get props => [data];
}

class InitializingError extends BrowseState {
  final String errorMessage;
  const InitializingError({required this.errorMessage, required super.data});

  @override
  List<Object> get props => [data, errorMessage];
}

class SuccessState extends BrowseState {
  const SuccessState({required super.data});

  @override
  List<Object> get props => [data];
}

class ErrorState extends BrowseState {
  final String errorMessage;
  const ErrorState({required super.data, required this.errorMessage});

  @override
  List<Object> get props => [data, errorMessage];
}

class MockupLocationDetected extends BrowseState {
  const MockupLocationDetected({required super.data});

  @override
  List<Object> get props => [data];
}

class MovedCurrentLocation extends BrowseState {
  const MovedCurrentLocation({required super.data});

  @override
  List<Object> get props => [data];
}

class NoBusinessInsideBounds extends BrowseState {
  final String message;

  const NoBusinessInsideBounds({required this.message, required super.data});

  @override
  List<Object> get props => [data, message];
}

class BusinessInsideBoundsFailed extends BrowseState {
  final String errorMessage;
  const BusinessInsideBoundsFailed({
    required this.errorMessage,
    required super.data,
  });

  @override
  List<Object> get props => [data, errorMessage];
}

class TokenExpired extends BrowseState {
  const TokenExpired({required super.data});

  @override
  List<Object> get props => [data];
}

class ZoomLevelNotification extends BrowseState {
  final String message;
  const ZoomLevelNotification({required this.message, required super.data});

  @override
  List<Object> get props => [message, data];
}

class BrowseStateData {
  // UI data state
  final BrowseViewMode viewMode;
  final BusinessLoadMode loadMode;
  final bool isLoadBusinessContainerExpanded;
  final LabelType? selectedLabelType;
  final MapType? selectedMapType;
  final bool isBusinessInsideBoundsLoading;
  final bool isBusinessInsideBoundsError;
  final bool isBusinessBySlsLoading;
  final bool isBusinessBySlsError;

  // Map data state
  final double currentZoom;
  final double rotation;
  final bool isLoadingCurrentLocation;
  final LatLng? currentLocation;
  final LatLng? northEastCorner;
  final LatLng? southWestCorner;
  final List<RequestedArea> requestedAreas;

  // Content data state
  final bool isLoadingBusiness;
  final List<TagData> businesses;
  final List<TagData> filteredBusinesses;
  final List<TagData> selectedBusinesses;
  final Project browseProject;

  // Load Business data state
  final List<Regency> regencies;
  final List<Subdistrict> subdistricts;
  final List<Village> villages;
  final List<Sls> sls;
  final Regency? selectedRegency;
  final Subdistrict? selectedSubdistrict;
  final Village? selectedVillage;
  final Sls? selectedSls;
  final bool isLoadingRegency;
  final bool isLoadingSubdistrict;
  final bool isLoadingVillage;
  final bool isLoadingSls;
  final bool isRegencyError;
  final bool isSubdistrictError;
  final bool isVillageError;
  final bool isSlsError;

  // User data state
  final User? currentUser;

  //Polygon attribute
  final List<Polygon> polygons;
  final bool isLoadingPolygon;
  final bool isDeletingPolygon;

  BrowseStateData({
    required this.viewMode,
    required this.loadMode,
    required this.isLoadBusinessContainerExpanded,
    this.selectedLabelType,
    this.selectedMapType,
    required this.isBusinessInsideBoundsLoading,
    required this.isBusinessInsideBoundsError,
    required this.isBusinessBySlsLoading,
    required this.isBusinessBySlsError,

    required this.currentZoom,
    required this.rotation,
    required this.isLoadingCurrentLocation,
    this.currentLocation,
    this.northEastCorner,
    this.southWestCorner,
    required this.requestedAreas,

    required this.isLoadingBusiness,
    required this.businesses,
    required this.filteredBusinesses,
    required this.selectedBusinesses,
    required this.browseProject,

    required this.regencies,
    required this.subdistricts,
    required this.villages,
    required this.sls,
    this.selectedRegency,
    this.selectedSubdistrict,
    this.selectedVillage,
    this.selectedSls,
    required this.isLoadingRegency,
    required this.isLoadingSubdistrict,
    required this.isLoadingVillage,
    required this.isLoadingSls,
    required this.isRegencyError,
    required this.isSubdistrictError,
    required this.isVillageError,
    required this.isSlsError,
    this.currentUser,

    required this.polygons,
    required this.isLoadingPolygon,
    required this.isDeletingPolygon,
  });
  BrowseStateData copyWith({
    BrowseViewMode? viewMode,
    BusinessLoadMode? loadMode,
    bool? isLoadBusinessContainerExpanded,
    LabelType? selectedLabelType,
    MapType? selectedMapType,
    bool? isBusinessInsideBoundsLoading,
    bool? isBusinessInsideBoundsError,
    bool? isBusinessBySlsLoading,
    bool? isBusinessBySlsError,

    double? currentZoom,
    double? rotation,
    bool? isLoadingCurrentLocation,
    LatLng? currentLocation,
    LatLng? northEastCorner,
    LatLng? southWestCorner,
    List<RequestedArea>? requestedAreas,

    bool? isLoadingBusiness,
    List<TagData>? businesses,
    List<TagData>? filteredBusinesses,
    List<TagData>? selectedBusinesses,
    Project? browseProject,

    List<Regency>? regencies,
    List<Subdistrict>? subdistricts,
    List<Village>? villages,
    List<Sls>? sls,
    Regency? selectedRegency,
    Subdistrict? selectedSubdistrict,
    Village? selectedVillage,
    Sls? selectedSls,
    bool? isLoadingRegency,
    bool? isLoadingSubdistrict,
    bool? isLoadingVillage,
    bool? isLoadingSls,
    bool? isRegencyError,
    bool? isSubdistrictError,
    bool? isVillageError,
    bool? isSlsError,
    bool? clearSelectedRegency,
    bool? clearSelectedSubdistrict,
    bool? clearSelectedVillage,
    bool? clearSelectedSls,

    User? currentUser,

    List<Polygon>? polygons,
    bool? isLoadingPolygon,
    bool? isDeletingPolygon,
  }) {
    return BrowseStateData(
      viewMode: viewMode ?? this.viewMode,
      loadMode: loadMode ?? this.loadMode,
      isLoadBusinessContainerExpanded:
          isLoadBusinessContainerExpanded ??
          this.isLoadBusinessContainerExpanded,
      selectedLabelType: selectedLabelType ?? this.selectedLabelType,
      selectedMapType: selectedMapType ?? this.selectedMapType,
      isBusinessInsideBoundsLoading:
          isBusinessInsideBoundsLoading ?? this.isBusinessInsideBoundsLoading,
      isBusinessInsideBoundsError:
          isBusinessInsideBoundsError ?? this.isBusinessInsideBoundsError,
      isBusinessBySlsLoading:
          isBusinessBySlsLoading ?? this.isBusinessBySlsLoading,
      isBusinessBySlsError: isBusinessBySlsError ?? this.isBusinessBySlsError,
      currentZoom: currentZoom ?? this.currentZoom,
      rotation: rotation ?? this.rotation,
      isLoadingCurrentLocation:
          isLoadingCurrentLocation ?? this.isLoadingCurrentLocation,
      currentLocation: currentLocation ?? this.currentLocation,
      northEastCorner: northEastCorner ?? this.northEastCorner,
      southWestCorner: southWestCorner ?? this.southWestCorner,
      requestedAreas: requestedAreas ?? this.requestedAreas,
      isLoadingBusiness: isLoadingBusiness ?? this.isLoadingBusiness,
      businesses: businesses ?? this.businesses,
      filteredBusinesses: filteredBusinesses ?? this.filteredBusinesses,
      selectedBusinesses: selectedBusinesses ?? this.selectedBusinesses,
      browseProject: browseProject ?? this.browseProject,
      regencies: regencies ?? this.regencies,
      subdistricts:
          (clearSelectedRegency ?? false)
              ? []
              : subdistricts ?? this.subdistricts,
      villages:
          (clearSelectedSubdistrict ?? false) ? [] : villages ?? this.villages,
      sls: (clearSelectedVillage ?? false) ? [] : sls ?? this.sls,
      selectedRegency:
          (clearSelectedRegency ?? false)
              ? null
              : selectedRegency ?? this.selectedRegency,
      selectedSubdistrict:
          (clearSelectedSubdistrict ?? false)
              ? null
              : selectedSubdistrict ?? this.selectedSubdistrict,
      selectedVillage:
          (clearSelectedVillage ?? false)
              ? null
              : selectedVillage ?? this.selectedVillage,
      selectedSls:
          (clearSelectedSls ?? false) ? null : selectedSls ?? this.selectedSls,
      isLoadingRegency: isLoadingRegency ?? this.isLoadingRegency,
      isLoadingSubdistrict: isLoadingSubdistrict ?? this.isLoadingSubdistrict,
      isLoadingVillage: isLoadingVillage ?? this.isLoadingVillage,
      isLoadingSls: isLoadingSls ?? this.isLoadingSls,
      isRegencyError: isRegencyError ?? this.isRegencyError,
      isSubdistrictError: isSubdistrictError ?? this.isSubdistrictError,
      isVillageError: isVillageError ?? this.isVillageError,
      isSlsError: isSlsError ?? this.isSlsError,
      currentUser: currentUser ?? this.currentUser,
      polygons: polygons ?? this.polygons,
      isLoadingPolygon: isLoadingPolygon ?? this.isLoadingPolygon,
      isDeletingPolygon: isDeletingPolygon ?? this.isDeletingPolygon,
    );
  }
}

enum BrowseViewMode { map, table }

enum BusinessLoadMode { area, screen }
