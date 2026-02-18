import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kendedes_mobile/bloc/browse/browse_event.dart';
import 'package:kendedes_mobile/bloc/browse/browse_state.dart';
import 'package:kendedes_mobile/classes/api_server_handler.dart';
import 'package:kendedes_mobile/classes/map_config.dart';
import 'package:kendedes_mobile/classes/repositories/auth_repository.dart';
import 'package:kendedes_mobile/classes/repositories/browse_repository.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/area_db_repository.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/browse_db_repository.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/polygon_db_repository.dart';
import 'package:kendedes_mobile/models/area/regency.dart';
import 'package:kendedes_mobile/models/area/sls.dart';
import 'package:kendedes_mobile/models/area/subdistrict.dart';
import 'package:kendedes_mobile/models/area/village.dart';
import 'package:kendedes_mobile/models/polygon.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/models/requested_area.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:kendedes_mobile/models/user.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

class BrowseBloc extends Bloc<BrowseEvent, BrowseState> {
  final Uuid _uuid = const Uuid();

  BrowseBloc() : super(InitializingStarted()) {
    on<Initialize>((event, emit) async {
      final User currentUser = AuthRepository().getUser();

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

      BrowseDbRepository browseDbRepository = BrowseDbRepository();
      if (!await browseDbRepository.hasBrowseProject(currentUser.id)) {
        await browseDbRepository.saveBrowseProject(
          projectId: _uuid.v4(),
          userId: currentUser.id,
        );
      }

      Project? browseProject = await browseDbRepository.getBrowseProject(
        currentUser.id,
      );

      final polygons = await PolygonDbRepository().getPolygonsForProject(
        browseProject?.id ?? '',
      );

      emit(
        InitializingSuccess(
          data: state.data.copyWith(
            currentUser: currentUser,
            regencies: regencies,
            browseProject: browseProject,
            polygons: polygons,
          ),
        ),
      );
    });

    on<GetCurrentLocation>((event, emit) async {
      emit(
        BrowseState(data: state.data.copyWith(isLoadingCurrentLocation: true)),
      );

      try {
        Position position = await _getCurrentPosition();

        if (position.isMocked) {
          emit(
            MockupLocationDetected(
              data: state.data.copyWith(isLoadingCurrentLocation: false),
            ),
          );
          return;
        }

        // Update current location in state
        emit(
          MovedCurrentLocation(
            data: state.data.copyWith(
              currentLocation: LatLng(position.latitude, position.longitude),
              isLoadingCurrentLocation: false,
            ),
          ),
        );
      } catch (e) {
        emit(
          ErrorState(
            errorMessage: e.toString(),
            data: state.data.copyWith(isLoadingCurrentLocation: false),
          ),
        );
      }
    });

    on<UpdateZoom>((event, emit) {
      emit(
        BrowseState(data: state.data.copyWith(currentZoom: event.zoomLevel)),
      );
    });

    on<UpdateRotation>((event, emit) {
      emit(BrowseState(data: state.data.copyWith(rotation: event.rotation)));
    });

    on<UpdateCurrentLocation>((event, emit) async {
      emit(
        BrowseState(
          data: state.data.copyWith(currentLocation: event.newPosition),
        ),
      );
    });

    on<UpdateVisibleMapBounds>((event, emit) {
      emit(
        BrowseState(
          data: state.data.copyWith(
            northEastCorner: event.ne,
            southWestCorner: event.sw,
          ),
        ),
      );
    });

    on<GetBusinessInsideBounds>((event, emit) async {
      if (state.data.currentZoom <
          MapConfig.minimumZoomToGetTaggingInsideBounds) {
        emit(
          ZoomLevelNotification(
            message:
                'Minimum zoom level untuk mendapatkan prelist usaha adalah '
                '${MapConfig.minimumZoomToGetTaggingInsideBounds}. Apakah akan memperbesar zoom?',
            data: state.data.copyWith(isBusinessInsideBoundsLoading: false),
          ),
        );
        return;
      } else {
        await ApiServerHandler.run(
          action: () async {
            emit(
              BrowseState(
                data: state.data.copyWith(isBusinessInsideBoundsLoading: true),
              ),
            );

            final ne = state.data.northEastCorner;
            final sw = state.data.southWestCorner;

            final businesses = await BrowseRepository().getBusinessesInBox(
              minLat: sw?.latitude ?? 0.0,
              minLng: sw?.longitude ?? 0.0,
              maxLat: ne?.latitude ?? 0.0,
              maxLng: ne?.longitude ?? 0.0,
            );

            final requestedArea = RequestedArea(
              northeast: ne ?? const LatLng(0, 0),
              southwest: sw ?? const LatLng(0, 0),
            );

            if (businesses.isEmpty) {
              emit(
                NoBusinessInsideBounds(
                  message: 'Tidak ada prelist usaha di area ini',
                  data: state.data.copyWith(
                    isBusinessInsideBoundsLoading: false,
                    requestedAreas: [
                      ...state.data.requestedAreas,
                      requestedArea,
                    ],
                    // isFirstTimeMapLoading: false,
                  ),
                ),
              );
            } else {
              // Create a copy of the current businesses list
              final updatedNearbyBusiness = List.of(state.data.businesses);

              // Use a Set for efficient duplicate checks
              final existingIds =
                  updatedNearbyBusiness.map((e) => e.id).toSet();

              // Add only new businesses
              updatedNearbyBusiness.addAll(
                businesses.where(
                  (business) => !existingIds.contains(business.id),
                ),
              );

              emit(
                BrowseState(
                  data: state.data.copyWith(
                    isBusinessInsideBoundsLoading: false,
                    businesses: updatedNearbyBusiness,
                    requestedAreas: [
                      ...state.data.requestedAreas,
                      requestedArea,
                    ],
                    // isFirstTimeMapLoading: false,
                  ),
                ),
              );
            }
          },
          onLoginExpired: (e) {
            emit(
              TokenExpired(
                data: state.data.copyWith(
                  isBusinessInsideBoundsLoading: false,
                  isBusinessInsideBoundsError: true,
                  // isFirstTimeMapLoading: false,
                ),
              ),
            );
          },
          onDataProviderError: (e) {
            emit(
              BusinessInsideBoundsFailed(
                errorMessage: e.message,
                data: state.data.copyWith(
                  isBusinessInsideBoundsLoading: false,
                  isBusinessInsideBoundsError: true,
                  // isFirstTimeMapLoading: false,
                ),
              ),
            );
          },
          onOtherError: (e) {
            emit(
              BusinessInsideBoundsFailed(
                errorMessage: e.toString(),
                data: state.data.copyWith(
                  isBusinessInsideBoundsLoading: false,
                  isBusinessInsideBoundsError: true,
                  // isFirstTimeMapLoading: false,
                ),
              ),
            );
          },
        );
      }
    });

    on<GetBusinessByArea>((event, emit) async {
      await ApiServerHandler.run(
        action: () async {
          emit(
            BrowseState(
              data: state.data.copyWith(isBusinessBySlsLoading: true),
            ),
          );

          final response = await BrowseRepository().getBusinessesBySls(
            event.sls.id,
          );

          List<TagData> businesses =
              response['businesses'] != null
                  ? List<Map<String, dynamic>>.from(
                    response['businesses'],
                  ).map((data) => TagData.fromJson(data)).toList()
                  : [];

          Sls slsWithPolygon = Sls.fromJson(response['sls']);
          Polygon updatedPolygon = slsWithPolygon.polygon!;

          await PolygonDbRepository().savePolygonWithPoints(updatedPolygon);

          // Check if project-polygon pair already exists before adding
          final existingPolygons = await PolygonDbRepository()
              .getPolygonsForProject(state.data.browseProject.id);

          final pairExists = existingPolygons.any(
            (polygon) => polygon.id == updatedPolygon.id,
          );

          if (!pairExists) {
            await PolygonDbRepository().addProjectPolygonPair(
              state.data.browseProject.id,
              updatedPolygon.id,
            );
          }

          if (businesses.isEmpty) {
            emit(
              NoBusinessInsideBounds(
                message: 'Tidak ada prelist usaha di SLS ${event.sls.name}',
                data: state.data.copyWith(isBusinessBySlsLoading: false),
              ),
            );
          } else {
            // Create a copy of the current businesses list
            final updatedNearbyBusiness = List.of(state.data.businesses);

            // Use a Set for efficient duplicate checks
            final existingIds = updatedNearbyBusiness.map((e) => e.id).toSet();

            // Add only new businesses
            updatedNearbyBusiness.addAll(
              businesses.where(
                (business) => !existingIds.contains(business.id),
              ),
            );

            emit(
              BusinessBySlsSuccess(
                centerLocation: LatLng(
                  businesses.first.positionLat,
                  businesses.first.positionLng,
                ),
                data: state.data.copyWith(
                  isBusinessBySlsLoading: false,
                  businesses: updatedNearbyBusiness,
                  polygons: [...state.data.polygons, updatedPolygon],
                ),
              ),
            );
          }
        },
        onLoginExpired: (e) {
          emit(
            TokenExpired(
              data: state.data.copyWith(
                isBusinessBySlsLoading: false,
                isBusinessBySlsError: true,
              ),
            ),
          );
        },
        onDataProviderError: (e) {
          emit(
            BusinessBySlsFailed(
              errorMessage: e.message,
              data: state.data.copyWith(
                isBusinessBySlsLoading: false,
                isBusinessBySlsError: true,
              ),
            ),
          );
        },
        onOtherError: (e) {
          emit(
            BusinessBySlsFailed(
              errorMessage: e.toString(),
              data: state.data.copyWith(
                isBusinessBySlsLoading: false,
                isBusinessBySlsError: true,
              ),
            ),
          );
        },
      );
    });

    on<SetBrowseViewMode>((event, emit) {
      emit(BrowseState(data: state.data.copyWith(viewMode: event.viewMode)));
    });

    on<SetBusinessLoadMode>((event, emit) {
      emit(BrowseState(data: state.data.copyWith(loadMode: event.loadMode)));
    });

    on<ToggleLoadBusinessContainer>((event, emit) {
      emit(
        BrowseState(
          data: state.data.copyWith(
            isLoadBusinessContainerExpanded:
                !state.data.isLoadBusinessContainerExpanded,
          ),
        ),
      );
    });

    on<SelectRegency>((event, emit) async {
      emit(
        BrowseState(
          data: state.data.copyWith(
            isLoadingSubdistrict: true,
            selectedRegency: event.regency,
            isRegencyError: false,
            isSubdistrictError: false,
            isVillageError: false,
            clearSelectedSubdistrict: true,
            clearSelectedVillage: true,
            clearSelectedSls: true,
            subdistricts: [],
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
        BrowseState(
          data: state.data.copyWith(
            subdistricts: subdistricts,
            isLoadingSubdistrict: false,
          ),
        ),
      );
    });

    on<SelectSubdistrict>((event, emit) async {
      await ApiServerHandler.run(
        action: () async {
          emit(
            BrowseState(
              data: state.data.copyWith(
                selectedSubdistrict: event.subdistrict,
                isLoadingVillage: true,
                isSubdistrictError: false,
                isVillageError: false,
                isSlsError: false,
                clearSelectedVillage: true,
                clearSelectedSls: true,
                villages: [],
              ),
            ),
          );
          List<Village> villages = [];
          if (event.subdistrict?.id != null) {
            villages = await BrowseRepository().getVillagesBySubdistrictId(
              event.subdistrict!.id,
            );
          }
          emit(
            BrowseState(
              data: state.data.copyWith(
                villages: villages,
                isLoadingVillage: false,
              ),
            ),
          );
        },
        onLoginExpired: (e) {
          emit(
            TokenExpired(data: state.data.copyWith(isLoadingVillage: false)),
          );
        },
        onDataProviderError: (e) {
          emit(
            BrowseState(
              data: state.data.copyWith(
                isLoadingVillage: false,
                isVillageError: true,
              ),
            ),
          );
        },
        onOtherError: (e) {
          emit(
            BrowseState(
              data: state.data.copyWith(
                isLoadingVillage: false,
                isVillageError: true,
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
            BrowseState(
              data: state.data.copyWith(
                isLoadingSls: true,
                selectedVillage: event.village,
                clearSelectedSls: true,
                isSlsError: false,
                sls: [],
              ),
            ),
          );
          List<Sls> sls = [];
          if (event.village != null) {
            sls = await BrowseRepository().getSlsByVillageId(event.village!.id);
          }
          emit(
            BrowseState(
              data: state.data.copyWith(isLoadingSls: false, sls: sls),
            ),
          );
        },
        onLoginExpired: (e) {
          emit(TokenExpired(data: state.data.copyWith(isLoadingSls: false)));
        },
        onDataProviderError: (e) {
          emit(
            BrowseState(
              data: state.data.copyWith(isLoadingSls: false, isSlsError: true),
            ),
          );
        },
        onOtherError: (e) {
          emit(
            BrowseState(
              data: state.data.copyWith(isLoadingSls: false, isSlsError: true),
            ),
          );
        },
      );
    });

    on<SelectSls>((event, emit) {
      emit(BrowseState(data: state.data.copyWith(selectedSls: event.sls)));
    });

    on<ClearSelectedRegency>((event, emit) {
      emit(
        BrowseState(
          data: state.data.copyWith(
            clearSelectedRegency: true,
            clearSelectedSubdistrict: true,
            clearSelectedVillage: true,
            clearSelectedSls: true,
          ),
        ),
      );
    });

    on<ClearSelectedSubdistrict>((event, emit) {
      emit(
        BrowseState(
          data: state.data.copyWith(
            clearSelectedSubdistrict: true,
            clearSelectedVillage: true,
            clearSelectedSls: true,
          ),
        ),
      );
    });

    on<ClearSelectedVillage>((event, emit) {
      emit(
        BrowseState(
          data: state.data.copyWith(
            clearSelectedVillage: true,
            clearSelectedSls: true,
          ),
        ),
      );
    });

    on<ClearSelectedSls>((event, emit) {
      emit(BrowseState(data: state.data.copyWith(clearSelectedSls: true)));
    });

    on<SelectLabelType>((event, emit) {
      emit(
        BrowseState(
          data: state.data.copyWith(selectedLabelType: event.labelTypeKey),
        ),
      );
    });

    on<SelectMapType>((event, emit) {
      emit(
        BrowseState(
          data: state.data.copyWith(selectedMapType: event.mapTypeKey),
        ),
      );
    });

    on<SetPolygonSideBarOpen>((event, emit) {
      final newDataState = state.data.copyWith(
        isPolygonSideBarOpen: event.isOpen,
      );
      if (event.isOpen) {
        emit(PolygonSideBarOpened(data: newDataState));
      } else {
        emit(PolygonSideBarClosed(data: newDataState));
      }
    });

    on<UpdatePolygon>((event, emit) async {
      emit(BrowseState(data: state.data.copyWith(isLoadingPolygon: true)));
      final polygons = await PolygonDbRepository().getPolygonsForProject(
        state.data.browseProject.id,
      );
      emit(
        BrowseState(
          data: state.data.copyWith(
            polygons: polygons,
            isLoadingPolygon: false,
          ),
        ),
      );
    });

    on<SelectPolygon>((event, emit) async {
      // Calculate the centroid (center) of the polygon from its points
      final center = _calculatePolygonCentroid(event.polygon.points);
      emit(
        PolygonSelected(
          center,
          data: state.data.copyWith(isPolygonSideBarOpen: false),
        ),
      );
    });

    on<DeletePolygon>((event, emit) async {
      emit(BrowseState(data: state.data.copyWith(isDeletingPolygon: true)));
      await PolygonDbRepository().removeProjectPolygonPair(
        state.data.browseProject.id,
        event.polygon.id,
      );
      final polygons = await PolygonDbRepository().getPolygonsForProject(
        state.data.browseProject.id,
      );

      emit(
        PolygonDeleted(
          data: state.data.copyWith(
            polygons: polygons,
            isDeletingPolygon: false,
          ),
        ),
      );
    });
  }

  Future<Position> _getCurrentPosition() async {
    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    // Get current position
    return await Geolocator.getCurrentPosition();
  }

  LatLng _calculatePolygonCentroid(List<LatLng> points) {
    if (points.isEmpty) {
      return LatLng(0, 0);
    }

    if (points.length == 1) {
      return points.first;
    }

    // Calculate centroid
    double centroidLat = 0;
    double centroidLng = 0;
    double signedArea = 0;

    // Calculate using the polygon centroid formula
    for (int i = 0; i < points.length; i++) {
      final current = points[i];
      final next = points[(i + 1) % points.length];

      final a =
          current.latitude * next.longitude - next.latitude * current.longitude;
      signedArea += a;
      centroidLat += (current.latitude + next.latitude) * a;
      centroidLng += (current.longitude + next.longitude) * a;
    }

    signedArea *= 0.5;

    LatLng center;
    if (signedArea.abs() < 1e-10) {
      // Fallback to simple average if the polygon is degenerate
      final avgLat =
          points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
      final avgLng =
          points.map((p) => p.longitude).reduce((a, b) => a + b) /
          points.length;
      center = LatLng(avgLat, avgLng);
    } else {
      centroidLat /= (6.0 * signedArea);
      centroidLng /= (6.0 * signedArea);
      center = LatLng(centroidLat, centroidLng);
    }

    return center;
  }
}
