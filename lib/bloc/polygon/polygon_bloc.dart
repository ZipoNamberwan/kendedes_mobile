import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/polygon_db_repository.dart';
import 'package:latlong2/latlong.dart';
import 'package:kendedes_mobile/bloc/polygon/polygon_event.dart';
import 'package:kendedes_mobile/bloc/polygon/polygon_state.dart';
import 'package:kendedes_mobile/classes/api_server_handler.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/area_db_repository.dart';
import 'package:kendedes_mobile/classes/repositories/polygon_repository.dart';
import 'package:kendedes_mobile/models/area/regency.dart';
import 'package:kendedes_mobile/models/area/sls.dart';
import 'package:kendedes_mobile/models/area/subdistrict.dart';
import 'package:kendedes_mobile/models/area/village.dart';
import 'package:kendedes_mobile/models/polygon.dart';

class PolygonBloc extends Bloc<PolygonEvent, PolygonState> {
  PolygonBloc() : super(Initialized()) {
    on<Initialize>((event, emit) async {
      emit(Initialized());
      emit(PolygonState(data: state.data.copyWith(isInitializing: true)));

      final bool isRegenciesEmpty = await AreaDbRepository().isRegenciesEmpty();
      final bool isSubdistrictsEmpty =
          await AreaDbRepository().isSubdistrictsEmpty();
      if (isRegenciesEmpty || isSubdistrictsEmpty) {
        await AreaDbRepository().insertBatchRegencies(
          Regency.getPredefinedRegencies(),
        );
        await AreaDbRepository().insertBatchSubdistricts(
          Subdistrict.getPredefinedSubdistricts(),
        );
      }
      final regencies = await AreaDbRepository().getRegencies();
      emit(
        PolygonState(
          data: state.data.copyWith(
            regencies: regencies,
            isLoadingRegency: false,
            isRegencyError: false,
            isInitializing: false,
          ),
        ),
      );
    });

    on<SelectRegency>((event, emit) async {
      emit(
        PolygonState(
          data: state.data.copyWith(
            isLoadingSubdistrict: true,
            selectedRegency: event.regency,
            isRegencyError: false,
            isSubdistrictError: false,
            isVillageError: false,
            isPolygonError: false,
          ),
        ),
      );
      List<Subdistrict> subdistricts = [];
      if (event.regency?.id != null) {
        subdistricts = await AreaDbRepository().getSubdistrictsByRegency(
          event.regency!.id,
        );
      }
      emit(
        PolygonState(
          data: state.data.copyWith(
            subdistricts: subdistricts,
            isLoadingSubdistrict: false,
            clearSelectedSubdistrict: true,
            clearSelectedVillage: true,
            clearSelectedPolygon: true,
            polygons: [],
            filteredPolygons: [],
          ),
        ),
      );
    });
    on<SelectSubdistrict>((event, emit) async {
      await ApiServerHandler.run(
        action: () async {
          emit(
            PolygonState(
              data: state.data.copyWith(
                isLoadingVillage: true,
                isLoadingPolygon: true,
                isVillageError: false,
                villages: [],
                polygons: [],
                filteredPolygons: [],
                selectedSubdistrict: event.subdistrict,
              ),
            ),
          );
          List<Village> villages = [];
          List<Polygon> polygons = [];
          if (event.subdistrict?.id != null) {
            villages = await PolygonRepository().getVillagesBySubdistrictId(
              event.subdistrict!.id,
            );
            for (var village in villages) {
              polygons.add(
                Polygon(
                  id: village.id,
                  shortName: village.name,
                  fullName: village.name,
                  type: PolygonType.village,
                  points: [],
                ),
              );
            }
          }
          emit(
            PolygonState(
              data: state.data.copyWith(
                villages: villages,
                polygons: polygons,
                filteredPolygons: polygons,
                isLoadingVillage: false,
                isLoadingPolygon: false,
                clearSelectedVillage: true,
                clearSelectedPolygon: true,
              ),
            ),
          );
        },
        onLoginExpired: (e) {},
        onDataProviderError: (e) {
          emit(
            PolygonState(
              data: state.data.copyWith(
                villages: [],
                polygons: [],
                filteredPolygons: [],
                isLoadingVillage: false,
                isLoadingPolygon: false,
                isVillageError: true,
                clearSelectedVillage: true,
                clearSelectedPolygon: true,
              ),
            ),
          );
        },
        onOtherError: (e) {
          emit(
            PolygonState(
              data: state.data.copyWith(
                villages: [],
                polygons: [],
                filteredPolygons: [],
                isLoadingVillage: false,
                isLoadingPolygon: false,
                isVillageError: true,
                clearSelectedVillage: true,
                clearSelectedPolygon: true,
              ),
            ),
          );
        },
      );
    });
    on<SelectVillage>((event, emit) async {
      await ApiServerHandler.run(
        action: () async {
          emit(
            PolygonState(
              data: state.data.copyWith(
                isLoadingPolygon: true,
                polygons: [],
                filteredPolygons: [],
                selectedVillage: event.village,
                clearSelectedPolygon: true,
                isPolygonError: false,
              ),
            ),
          );
          List<Sls> sls = [];
          List<Polygon> polygons = [];
          if (event.village != null) {
            sls = await PolygonRepository().getSlsByVillageId(
              event.village!.id,
            );
          }
          for (var sl in sls) {
            polygons.add(
              Polygon(
                id: sl.id,
                shortName: sl.name,
                fullName: sl.name,
                type: PolygonType.sls,
                points: [],
              ),
            );
          }
          emit(
            PolygonState(
              data: state.data.copyWith(
                polygons: polygons,
                filteredPolygons: polygons,
                isLoadingPolygon: false,
              ),
            ),
          );
        },
        onLoginExpired: (e) {},
        onDataProviderError: (e) {
          emit(
            PolygonState(
              data: state.data.copyWith(
                polygons: [],
                filteredPolygons: [],
                isLoadingPolygon: false,
                isPolygonError: true,
                clearSelectedPolygon: true,
              ),
            ),
          );
        },
        onOtherError: (e) {
          emit(
            PolygonState(
              data: state.data.copyWith(
                polygons: [],
                filteredPolygons: [],
                isLoadingPolygon: false,
                isPolygonError: true,
                clearSelectedPolygon: true,
              ),
            ),
          );
        },
      );
    });

    on<SelectPolygon>((event, emit) async {
      emit(
        PolygonState(data: state.data.copyWith(selectedPolygon: event.polygon)),
      );
    });

    on<SearchPolygon>((event, emit) async {
      final newQuery = event.query?.toLowerCase().trim() ?? '';
      final resetSearch = event.reset ?? false;

      List<Polygon> filtered = [];

      if (resetSearch || newQuery.isEmpty) {
        // If reset or empty query, show all polygons
        filtered = state.data.polygons;
      } else {
        // Filter polygons based on query
        filtered =
            state.data.polygons.where((polygon) {
              final id = polygon.id.toLowerCase();
              final fullName = polygon.fullName.toLowerCase();
              final shortName = polygon.shortName.toLowerCase();

              return id.contains(newQuery) ||
                  fullName.contains(newQuery) ||
                  shortName.contains(newQuery);
            }).toList();
      }

      final newDataState = state.data.copyWith(
        filteredPolygons: filtered,
        searchQuery: resetSearch ? null : newQuery,
        clearSearchQuery: resetSearch,
        clearSelectedPolygon: true,
      );

      if (resetSearch) {
        emit(SearchQueryCleared(data: newDataState));
      } else {
        emit(PolygonState(data: newDataState));
      }
    });

    on<DownloadInstallPolygon>((event, emit) async {
      await ApiServerHandler.run(
        action: () async {
          emit(PolygonState(data: state.data.copyWith(isDownloading: true)));
          final result = await PolygonRepository().downloadPolygonGeoJson(
            state.data.selectedPolygon?.id ?? '',
            state.data.selectedPolygon?.type.name ?? '',
          );

          // Extract coordinates from GeoJSON
          List<LatLng> polygonPoints = _extractPolygonCoordinates(result);

          // Update the selected polygon with extracted coordinates
          final updatedPolygon = state.data.selectedPolygon?.copyWith(
            points: polygonPoints,
          );

          await PolygonDbRepository().savePolygonWithPoints(updatedPolygon!);

          // Check if project-polygon pair already exists before adding
          final existingPolygons = await PolygonDbRepository()
              .getPolygonsForProject(event.projectId);

          final pairExists = existingPolygons.any(
            (polygon) => polygon.id == updatedPolygon.id,
          );

          if (!pairExists) {
            await PolygonDbRepository().addProjectPolygonPair(
              event.projectId,
              updatedPolygon.id,
            );
          }

          // Update state with the polygon containing coordinates
          emit(
            PolygonDownloadSuccess(
              data: state.data.copyWith(
                selectedPolygon: updatedPolygon,
                isDownloading: false,
              ),
            ),
          );
        },
        onLoginExpired: (e) {},
        onDataProviderError: (e) {
          emit(
            PolygonDownloadFailed(
              errorMessage: e.message,
              data: state.data.copyWith(isDownloading: false),
            ),
          );
        },
        onOtherError: (e) {
          emit(
            PolygonDownloadFailed(
              errorMessage: e.toString(),
              data: state.data.copyWith(isDownloading: false),
            ),
          );
        },
      );
    });
  }

  // Helper method to extract coordinates from GeoJSON
  List<LatLng> _extractPolygonCoordinates(Map<String, dynamic> geoJson) {
    List<LatLng> coordinates = [];

    try {
      // Get features array
      final features = geoJson['features'] as List<dynamic>?;
      if (features == null || features.isEmpty) {
        throw Exception('GeoJSON does not contain any features');
      }

      // Get first feature's geometry
      final firstFeature = features[0] as Map<String, dynamic>;
      final geometry = firstFeature['geometry'] as Map<String, dynamic>?;
      if (geometry == null) {
        throw Exception('Feature does not contain geometry data');
      }

      // Get coordinates based on geometry type
      final geometryType = geometry['type'] as String?;
      final coords = geometry['coordinates'] as List<dynamic>?;
      if (coords == null) {
        throw Exception('Geometry does not contain coordinates data');
      }

      if (geometryType == 'MultiPolygon') {
        // MultiPolygon: [[[lng, lat], [lng, lat], ...]]
        final multiPolygon = coords;
        if (multiPolygon.isEmpty) {
          throw Exception('MultiPolygon coordinates array is empty');
        }

        final polygon = multiPolygon[0] as List<dynamic>; // Take first polygon
        if (polygon.isEmpty) {
          throw Exception('Polygon coordinates array is empty');
        }

        final ring = polygon[0] as List<dynamic>; // Take outer ring
        if (ring.isEmpty) {
          throw Exception('Polygon ring coordinates array is empty');
        }

        coordinates =
            ring.map((point) {
              final pointList = point as List<dynamic>;
              if (pointList.length < 2) {
                throw Exception(
                  'Invalid coordinate point: requires at least 2 values (lng, lat)',
                );
              }
              final lng = (pointList[0] as num).toDouble();
              final lat = (pointList[1] as num).toDouble();
              return LatLng(lat, lng);
            }).toList();
      } else if (geometryType == 'Polygon') {
        // Polygon: [[lng, lat], [lng, lat], ...]
        final polygon = coords;
        if (polygon.isEmpty) {
          throw Exception('Polygon coordinates array is empty');
        }

        final ring = polygon[0] as List<dynamic>; // Take outer ring
        if (ring.isEmpty) {
          throw Exception('Polygon ring coordinates array is empty');
        }

        coordinates =
            ring.map((point) {
              final pointList = point as List<dynamic>;
              if (pointList.length < 2) {
                throw Exception(
                  'Invalid coordinate point: requires at least 2 values (lng, lat)',
                );
              }
              final lng = (pointList[0] as num).toDouble();
              final lat = (pointList[1] as num).toDouble();
              return LatLng(lat, lng);
            }).toList();
      } else {
        throw Exception(
          'Unsupported geometry type: $geometryType. Only Polygon and MultiPolygon are supported',
        );
      }

      if (coordinates.isEmpty) {
        throw Exception('No valid coordinates found in GeoJSON data');
      }
    } catch (e) {
      // Re-throw with more context if it's already our custom exception
      if (e.toString().startsWith('Exception:')) {
        rethrow;
      }
      // Wrap other errors with context
      throw Exception('Failed to extract coordinates from GeoJSON: $e');
    }

    return coordinates;
  }
}
