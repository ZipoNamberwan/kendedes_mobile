import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/classes/map_config.dart';
import 'package:kendedes_mobile/models/area/regency.dart';
import 'package:kendedes_mobile/models/area/sls.dart';
import 'package:kendedes_mobile/models/area/subdistrict.dart';
import 'package:kendedes_mobile/models/area/village.dart';
import 'package:kendedes_mobile/models/label_type.dart';
import 'package:kendedes_mobile/models/map_type.dart';
import 'package:kendedes_mobile/models/polygon.dart';
import 'package:kendedes_mobile/models/requested_area.dart';
import 'package:kendedes_mobile/models/sls_with_business.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:kendedes_mobile/models/user.dart';
import 'package:latlong2/latlong.dart';

class MoveState extends Equatable {
  final MoveStateData data;

  const MoveState({required this.data});

  @override
  List<Object> get props => [data];
}

class InitializingStarted extends MoveState {
  final String message;

  InitializingStarted({required this.message})
    : super(
        data: MoveStateData(
          currentZoom: MapConfig.initialZoom,
          isDeletingPolygon: false,
          isLoadingCurrentLocation: false,
          isLoadingPolygon: false,
          isLoadingBusiness: false,
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
          isPolygonSideBarOpen: false,
          isLoadingRegency: false,
          isLoadingSubdistrict: false,
          isLoadingVillage: false,
          isLoadingSls: false,
          isRegencyError: false,
          isSubdistrictError: false,
          isVillageError: false,
          isSlsError: false,
          isSaveToLocalDbByArea: true,
          isSaveToLocalDbByScreen: true,
          slsWithBusinessList: [],
          filteredSlsWithBusinessList: [],
          isSlsWithBusinessSidebarOpen: false,
          isDeletingSlsWithBusiness: false,
          isMoveSideBarOpen: false,
          slsFilterOptions: [],
          isFindingSls: false,
          isFindingSlsError: false,
          showFinder: false,
          slsWithBusinessListForUpdate: [],
          updatedSlsWithBusinessId: [],
          isUpdatingSlsError: false,
          refreshingSlsIds: [],
        ),
      );

  @override
  List<Object> get props => [data];
}

class InitializingSuccess extends MoveState {
  const InitializingSuccess({required super.data});

  @override
  List<Object> get props => [data];
}

class InitializingError extends MoveState {
  final String errorMessage;
  const InitializingError({required this.errorMessage, required super.data});

  @override
  List<Object> get props => [data, errorMessage];
}

class SuccessState extends MoveState {
  const SuccessState({required super.data});

  @override
  List<Object> get props => [data];
}

class ErrorState extends MoveState {
  final String errorMessage;
  const ErrorState({required super.data, required this.errorMessage});

  @override
  List<Object> get props => [data, errorMessage];
}

class MockupLocationDetected extends MoveState {
  const MockupLocationDetected({required super.data});

  @override
  List<Object> get props => [data];
}

class MovedCurrentLocation extends MoveState {
  const MovedCurrentLocation({required super.data});

  @override
  List<Object> get props => [data];
}

class NoBusinessInsideBounds extends MoveState {
  final String message;

  const NoBusinessInsideBounds({required this.message, required super.data});

  @override
  List<Object> get props => [data, message];
}

class BusinessInsideBoundsFailed extends MoveState {
  final String errorMessage;
  const BusinessInsideBoundsFailed({
    required this.errorMessage,
    required super.data,
  });

  @override
  List<Object> get props => [data, errorMessage];
}

class BusinessBySlsFailed extends MoveState {
  final String errorMessage;
  const BusinessBySlsFailed({required this.errorMessage, required super.data});

  @override
  List<Object> get props => [data, errorMessage];
}

class BusinessBySlsSuccess extends MoveState {
  final LatLng centerLocation;
  const BusinessBySlsSuccess({
    required super.data,
    required this.centerLocation,
  });

  @override
  List<Object> get props => [data, centerLocation];
}

class TokenExpired extends MoveState {
  const TokenExpired({required super.data});

  @override
  List<Object> get props => [data];
}

class ZoomLevelNotification extends MoveState {
  final String message;
  const ZoomLevelNotification({required this.message, required super.data});

  @override
  List<Object> get props => [message, data];
}

class PolygonSideBarOpened extends MoveState {
  const PolygonSideBarOpened({required super.data});

  @override
  List<Object> get props => [data];
}

class PolygonSideBarClosed extends MoveState {
  const PolygonSideBarClosed({required super.data});

  @override
  List<Object> get props => [data];
}

class SlsWithBusinessSidebarOpened extends MoveState {
  const SlsWithBusinessSidebarOpened({required super.data});

  @override
  List<Object> get props => [data];
}

class SlsWithBusinessSidebarClosed extends MoveState {
  const SlsWithBusinessSidebarClosed({required super.data});

  @override
  List<Object> get props => [data];
}

class PolygonSelected extends MoveState {
  final LatLng polygonCenter;
  const PolygonSelected(this.polygonCenter, {required super.data});

  @override
  List<Object> get props => [data, polygonCenter];
}

class PolygonDeleted extends MoveState {
  const PolygonDeleted({required super.data});

  @override
  List<Object> get props => [data];
}

class SlsWithBusinessDeleted extends MoveState {
  const SlsWithBusinessDeleted({required super.data});

  @override
  List<Object> get props => [data];
}

class MoveSideBarOpened extends MoveState {
  const MoveSideBarOpened({required super.data});

  @override
  List<Object> get props => [data];
}

class MoveSideBarClosed extends MoveState {
  const MoveSideBarClosed({required super.data});

  @override
  List<Object> get props => [data];
}

class SearchQueryCleared extends MoveState {
  const SearchQueryCleared({required super.data});

  @override
  List<Object> get props => [data];
}

class AllFilterCleared extends MoveState {
  const AllFilterCleared({required super.data});

  @override
  List<Object> get props => [data];
}

class BusinessSelected extends MoveState {
  const BusinessSelected({required super.data});

  @override
  List<Object> get props => [data];
}

class SearchSlsWithBusinessQueryCleared extends MoveState {
  const SearchSlsWithBusinessQueryCleared({required super.data});

  @override
  List<Object> get props => [data];
}

class SlsWithBusinessNeedUpdate extends MoveState {
  const SlsWithBusinessNeedUpdate({required super.data});

  @override
  List<Object> get props => [data];
}

class ErrorUpdateSlsBusiness extends MoveState {
  const ErrorUpdateSlsBusiness({required super.data});

  @override
  List<Object> get props => [data];
}

class MoveStateData {
  // UI data state
  final bool isLoadBusinessContainerExpanded;
  final LabelType? selectedLabelType;
  final MapType? selectedMapType;
  final bool isBusinessInsideBoundsLoading;
  final bool isBusinessInsideBoundsError;
  final bool isBusinessBySlsLoading;
  final bool isBusinessBySlsError;
  final bool isPolygonSideBarOpen;
  final bool isSlsWithBusinessSidebarOpen;
  final bool isDeletingSlsWithBusiness;
  final bool isMoveSideBarOpen;

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
  final List<SlsWithBusiness> slsWithBusinessList;
  final List<SlsWithBusiness> filteredSlsWithBusinessList;
  final String? slsWithBusinessSearchQuery;

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
  final bool isSaveToLocalDbByArea;
  final bool isSaveToLocalDbByScreen;

  // User data state
  final User? currentUser;

  // Polygon attribute
  final List<Polygon> polygons;
  final bool isLoadingPolygon;
  final bool isDeletingPolygon;
  // The single SLS polygon currently drawn on the map (one area/sls at a time)
  final Polygon? currentSlsPolygon;

  // Filter attribute
  final String? searchQuery;
  final List<Sls> slsFilterOptions;
  final Sls? selectedSlsFilter;

  // SLS pointer state data
  final Sls? slsFinder;
  final bool isFindingSls;
  final bool isFindingSlsError;
  final String? slsFinderErrorMessage;
  final bool showFinder;

  // Business data update state
  final List<SlsWithBusiness> slsWithBusinessListForUpdate;
  final SlsWithBusiness? updatingSlsWithBusinessId;
  final List<String> updatedSlsWithBusinessId;
  final bool isUpdatingSlsError;
  final String? updatingSlsErrorMessage;
  final bool? resetUpdatingSls;
  final bool? resetUpdatingSlsErrorMessage;
  final List<String> refreshingSlsIds;

  MoveStateData({
    required this.isLoadBusinessContainerExpanded,
    this.selectedLabelType,
    this.selectedMapType,
    required this.isBusinessInsideBoundsLoading,
    required this.isBusinessInsideBoundsError,
    required this.isBusinessBySlsLoading,
    required this.isBusinessBySlsError,
    required this.isPolygonSideBarOpen,
    required this.isSlsWithBusinessSidebarOpen,
    required this.isDeletingSlsWithBusiness,
    required this.isMoveSideBarOpen,

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
    required this.slsWithBusinessList,
    required this.filteredSlsWithBusinessList,
    this.slsWithBusinessSearchQuery,

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
    required this.isSaveToLocalDbByArea,
    required this.isSaveToLocalDbByScreen,

    this.currentUser,

    required this.polygons,
    required this.isLoadingPolygon,
    required this.isDeletingPolygon,
    this.currentSlsPolygon,

    this.searchQuery,
    this.selectedSlsFilter,
    required this.slsFilterOptions,

    this.slsFinder,
    required this.isFindingSls,
    required this.isFindingSlsError,
    this.slsFinderErrorMessage,
    required this.showFinder,

    required this.slsWithBusinessListForUpdate,
    this.updatingSlsWithBusinessId,
    required this.updatedSlsWithBusinessId,
    required this.isUpdatingSlsError,
    this.updatingSlsErrorMessage,
    this.resetUpdatingSls,
    this.resetUpdatingSlsErrorMessage,
    required this.refreshingSlsIds,
  });
  MoveStateData copyWith({
    bool? isLoadBusinessContainerExpanded,
    LabelType? selectedLabelType,
    MapType? selectedMapType,
    bool? isBusinessInsideBoundsLoading,
    bool? isBusinessInsideBoundsError,
    bool? isBusinessBySlsLoading,
    bool? isBusinessBySlsError,
    bool? isPolygonSideBarOpen,
    bool? isSlsWithBusinessSidebarOpen,
    bool? isDeletingSlsWithBusiness,
    bool? isMoveSideBarOpen,

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
    List<SlsWithBusiness>? slsWithBusinessList,
    List<SlsWithBusiness>? filteredSlsWithBusinessList,
    String? slsWithBusinessSearchQuery,
    bool? resetSlsWithBusinessSearchQuery,

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
    bool? isSaveToLocalDbByArea,
    bool? isSaveToLocalDbByScreen,

    User? currentUser,

    List<Polygon>? polygons,
    bool? isLoadingPolygon,
    bool? isDeletingPolygon,
    Polygon? currentSlsPolygon,
    bool? clearCurrentSlsPolygon,

    String? searchQuery,
    List<Sls>? slsFilterOptions,
    Sls? selectedSlsFilter,
    bool? resetAllFilter,
    bool? resetSearchQuery,
    bool? resetSlsFilter,

    Sls? slsFinder,
    bool? isFindingSls,
    bool? isFindingSlsError,
    String? slsFinderErrorMessage,
    bool? resetSlsFinder,
    bool? resetSlsFinderErrorMessage,
    bool? showFinder,

    List<SlsWithBusiness>? slsWithBusinessListForUpdate,
    SlsWithBusiness? updatingSlsWithBusinessId,
    List<String>? updatedSlsWithBusinessId,
    bool? isUpdatingSlsError,
    String? updatingSlsErrorMessage,
    bool? resetUpdatingSls,
    bool? resetUpdatingSlsErrorMessage,
    List<String>? refreshingSlsIds,
  }) {
    return MoveStateData(
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
      isPolygonSideBarOpen: isPolygonSideBarOpen ?? this.isPolygonSideBarOpen,
      isSlsWithBusinessSidebarOpen:
          isSlsWithBusinessSidebarOpen ?? this.isSlsWithBusinessSidebarOpen,
      isDeletingSlsWithBusiness:
          isDeletingSlsWithBusiness ?? this.isDeletingSlsWithBusiness,
      isMoveSideBarOpen: isMoveSideBarOpen ?? this.isMoveSideBarOpen,
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
      slsWithBusinessList: slsWithBusinessList ?? this.slsWithBusinessList,
      filteredSlsWithBusinessList:
          filteredSlsWithBusinessList ?? this.filteredSlsWithBusinessList,
      slsWithBusinessSearchQuery:
          resetSlsWithBusinessSearchQuery == true
              ? null
              : slsWithBusinessSearchQuery ?? this.slsWithBusinessSearchQuery,
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
      isSaveToLocalDbByArea:
          isSaveToLocalDbByArea ?? this.isSaveToLocalDbByArea,
      isSaveToLocalDbByScreen:
          isSaveToLocalDbByScreen ?? this.isSaveToLocalDbByScreen,

      currentUser: currentUser ?? this.currentUser,

      polygons: polygons ?? this.polygons,
      isLoadingPolygon: isLoadingPolygon ?? this.isLoadingPolygon,
      isDeletingPolygon: isDeletingPolygon ?? this.isDeletingPolygon,
      currentSlsPolygon:
          (clearCurrentSlsPolygon ?? false)
              ? null
              : currentSlsPolygon ?? this.currentSlsPolygon,

      searchQuery:
          resetAllFilter ?? false
              ? null
              : resetSearchQuery ?? false
              ? null
              : searchQuery ?? this.searchQuery,
      selectedSlsFilter:
          resetAllFilter ?? false
              ? null
              : resetSlsFilter ?? false
              ? null
              : selectedSlsFilter ?? this.selectedSlsFilter,
      slsFilterOptions: slsFilterOptions ?? this.slsFilterOptions,
      slsFinder: resetSlsFinder == true ? null : slsFinder ?? this.slsFinder,
      isFindingSls: isFindingSls ?? this.isFindingSls,
      isFindingSlsError: isFindingSlsError ?? this.isFindingSlsError,
      slsFinderErrorMessage:
          resetSlsFinderErrorMessage == true
              ? null
              : slsFinderErrorMessage ?? this.slsFinderErrorMessage,
      showFinder: showFinder ?? this.showFinder,

      slsWithBusinessListForUpdate:
          slsWithBusinessListForUpdate ?? this.slsWithBusinessListForUpdate,
      updatingSlsWithBusinessId:
          resetUpdatingSls == true
              ? null
              : updatingSlsWithBusinessId ?? this.updatingSlsWithBusinessId,
      updatedSlsWithBusinessId:
          updatedSlsWithBusinessId ?? this.updatedSlsWithBusinessId,
      isUpdatingSlsError: isUpdatingSlsError ?? this.isUpdatingSlsError,
      updatingSlsErrorMessage:
          resetUpdatingSlsErrorMessage == true
              ? null
              : updatingSlsErrorMessage ?? this.updatingSlsErrorMessage,
      refreshingSlsIds: refreshingSlsIds ?? this.refreshingSlsIds,
    );
  }

  List<TagData> getSortedFilteredBusinesses() {
    if (currentLocation == null) {
      return List.from(filteredBusinesses);
    }

    final lat = currentLocation!.latitude;
    final lng = currentLocation!.longitude;
    List<TagData> sortedBusinesses = List.from(filteredBusinesses);

    sortedBusinesses.sort((a, b) {
      final aIsZero = a.positionLat == 0 && a.positionLng == 0;
      final bIsZero = b.positionLat == 0 && b.positionLng == 0;

      if (aIsZero && bIsZero) return 0;
      if (aIsZero) return 1;
      if (bIsZero) return -1;

      final distA =
          (a.positionLat - lat) * (a.positionLat - lat) +
          (a.positionLng - lng) * (a.positionLng - lng);
      final distB =
          (b.positionLat - lat) * (b.positionLat - lat) +
          (b.positionLng - lng) * (b.positionLng - lng);

      return distA.compareTo(distB);
    });

    return sortedBusinesses;
  }

  bool isBusinessFilterActive() {
    return (searchQuery?.isNotEmpty ?? false) || selectedSlsFilter != null;
  }
}