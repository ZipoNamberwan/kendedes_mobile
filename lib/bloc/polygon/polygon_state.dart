import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/models/area/regency.dart';
import 'package:kendedes_mobile/models/area/subdistrict.dart';
import 'package:kendedes_mobile/models/area/village.dart';
import 'package:kendedes_mobile/models/polygon.dart';

class PolygonState extends Equatable {
  final PolygonStateData data;

  const PolygonState({required this.data});

  @override
  List<Object> get props => [data];
}

class Initialized extends PolygonState {
  Initialized()
    : super(
        data: PolygonStateData(
          regencies: [],
          subdistricts: [],
          villages: [],
          polygons: [],
          filteredPolygons: [],
          selectedRegency: null,
          selectedSubdistrict: null,
          selectedVillage: null,
          selectedPolygon: null,
          isLoadingRegency: false,
          isLoadingSubdistrict: false,
          isLoadingVillage: false,
          isRegencyError: false,
          isSubdistrictError: false,
          isVillageError: false,
          isPolygonError: false,
          isInitializing: false,
          isLoadingPolygon: false,
          isDownloading: false,
        ),
      );
}

class PolygonDownloadSuccess extends PolygonState {
  const PolygonDownloadSuccess({required super.data});

  @override
  List<Object> get props => [data];
}

class PolygonDownloadFailed extends PolygonState {
  final String errorMessage;
  const PolygonDownloadFailed({
    required this.errorMessage,
    required super.data,
  });

  @override
  List<Object> get props => [data, errorMessage];
}

class SearchQueryCleared extends PolygonState {
  const SearchQueryCleared({required super.data});

  @override
  List<Object> get props => [data];
}

class PolygonStateData {
  final List<Regency> regencies;
  final List<Subdistrict> subdistricts;
  final List<Village> villages;
  final List<Polygon> polygons;
  final List<Polygon> filteredPolygons;
  final String? searchQuery;

  final Regency? selectedRegency;
  final Subdistrict? selectedSubdistrict;
  final Village? selectedVillage;
  final Polygon? selectedPolygon;

  final bool isLoadingRegency;
  final bool isLoadingSubdistrict;
  final bool isLoadingVillage;
  final bool isLoadingPolygon;

  final bool isDownloading;

  final bool isRegencyError;
  final bool isSubdistrictError;
  final bool isVillageError;
  final bool isPolygonError;

  final bool isInitializing;

  PolygonStateData({
    required this.regencies,
    required this.subdistricts,
    required this.villages,
    required this.polygons,
    required this.filteredPolygons,
    this.searchQuery,
    this.selectedRegency,
    this.selectedSubdistrict,
    this.selectedVillage,
    this.selectedPolygon,
    required this.isLoadingRegency,
    required this.isLoadingSubdistrict,
    required this.isLoadingVillage,
    required this.isLoadingPolygon,
    required this.isDownloading,
    required this.isRegencyError,
    required this.isSubdistrictError,
    required this.isVillageError,
    required this.isPolygonError,
    required this.isInitializing,
  });
  PolygonStateData copyWith({
    List<Regency>? regencies,
    List<Subdistrict>? subdistricts,
    List<Village>? villages,
    List<Polygon>? polygons,
    List<Polygon>? filteredPolygons,
    String? searchQuery,
    bool? clearSearchQuery,
    Regency? selectedRegency,
    Subdistrict? selectedSubdistrict,
    Village? selectedVillage,
    Polygon? selectedPolygon,
    bool? clearSelectedRegency,
    bool? clearSelectedSubdistrict,
    bool? clearSelectedVillage,
    bool? clearSelectedPolygon,
    bool? isLoadingRegency,
    bool? isLoadingSubdistrict,
    bool? isLoadingVillage,
    bool? isLoadingPolygon,
    bool? isDownloading,
    bool? isRegencyError,
    bool? isSubdistrictError,
    bool? isVillageError,
    bool? isPolygonError,
    bool? isInitializing,
  }) {
    return PolygonStateData(
      regencies: regencies ?? this.regencies,
      subdistricts: subdistricts ?? this.subdistricts,
      villages: villages ?? this.villages,
      polygons: polygons ?? this.polygons,
      filteredPolygons: filteredPolygons ?? this.filteredPolygons,
      searchQuery:
          (clearSearchQuery ?? false) ? null : searchQuery ?? this.searchQuery,
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
      selectedPolygon:
          (clearSelectedPolygon ?? false)
              ? null
              : selectedPolygon ?? this.selectedPolygon,
      isLoadingRegency: isLoadingRegency ?? this.isLoadingRegency,
      isLoadingSubdistrict: isLoadingSubdistrict ?? this.isLoadingSubdistrict,
      isLoadingVillage: isLoadingVillage ?? this.isLoadingVillage,
      isDownloading: isDownloading ?? this.isDownloading,
      isRegencyError: isRegencyError ?? this.isRegencyError,
      isSubdistrictError: isSubdistrictError ?? this.isSubdistrictError,
      isVillageError: isVillageError ?? this.isVillageError,
      isPolygonError: isPolygonError ?? this.isPolygonError,
      isInitializing: isInitializing ?? this.isInitializing,
      isLoadingPolygon: isLoadingPolygon ?? this.isLoadingPolygon,
    );
  }
}
