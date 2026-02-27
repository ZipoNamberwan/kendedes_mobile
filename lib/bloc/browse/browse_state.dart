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
          isSlsWithBusinessSidebarOpen: false,
          isDeletingSlsWithBusiness: false,
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

class BusinessBySlsFailed extends BrowseState {
  final String errorMessage;
  const BusinessBySlsFailed({required this.errorMessage, required super.data});

  @override
  List<Object> get props => [data, errorMessage];
}

class BusinessBySlsSuccess extends BrowseState {
  final LatLng centerLocation;
  const BusinessBySlsSuccess({
    required super.data,
    required this.centerLocation,
  });

  @override
  List<Object> get props => [data, centerLocation];
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

class PolygonSideBarOpened extends BrowseState {
  const PolygonSideBarOpened({required super.data});

  @override
  List<Object> get props => [data];
}

class PolygonSideBarClosed extends BrowseState {
  const PolygonSideBarClosed({required super.data});

  @override
  List<Object> get props => [data];
}

class SlsWithBusinessSidebarOpened extends BrowseState {
  const SlsWithBusinessSidebarOpened({required super.data});

  @override
  List<Object> get props => [data];
}

class SlsWithBusinessSidebarClosed extends BrowseState {
  const SlsWithBusinessSidebarClosed({required super.data});

  @override
  List<Object> get props => [data];
}

class PolygonSelected extends BrowseState {
  final LatLng polygonCenter;
  const PolygonSelected(this.polygonCenter, {required super.data});

  @override
  List<Object> get props => [data, polygonCenter];
}

class PolygonDeleted extends BrowseState {
  const PolygonDeleted({required super.data});

  @override
  List<Object> get props => [data];
}

class SlsWithBusinessDeleted extends BrowseState {
  const SlsWithBusinessDeleted({required super.data});

  @override
  List<Object> get props => [data];
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
  final bool isPolygonSideBarOpen;
  final bool isSlsWithBusinessSidebarOpen;
  final bool isDeletingSlsWithBusiness;

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
    required this.isPolygonSideBarOpen,
    required this.isSlsWithBusinessSidebarOpen,
    required this.isDeletingSlsWithBusiness,

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
    bool? isPolygonSideBarOpen,
    bool? isSlsWithBusinessSidebarOpen,
    bool? isDeletingSlsWithBusiness,

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
      isPolygonSideBarOpen: isPolygonSideBarOpen ?? this.isPolygonSideBarOpen,
      isSlsWithBusinessSidebarOpen:
          isSlsWithBusinessSidebarOpen ?? this.isSlsWithBusinessSidebarOpen,
      isDeletingSlsWithBusiness:
          isDeletingSlsWithBusiness ?? this.isDeletingSlsWithBusiness,

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
    );
  }
}

enum BrowseViewMode { map, table }

enum BusinessLoadMode { area, screen }
