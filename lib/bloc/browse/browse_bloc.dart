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
import 'package:kendedes_mobile/models/sls_with_business.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:kendedes_mobile/models/user.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

class BrowseBloc extends Bloc<BrowseEvent, BrowseState> {
  final Uuid _uuid = const Uuid();

  BrowseBloc() : super(InitializingStarted(message: 'Memuat data...')) {
    on<Initialize>((event, emit) async {
      try {
        final User currentUser = AuthRepository().getUser();

        // 1. Init area data if not exist (regency and subdistrict only, village and sls will be fetched when user select the regency and subdistrict)
        final bool isRegenciesEmpty =
            await AreaDbRepository().isRegenciesEmpty();
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

        // 2. Init browse project list
        List<Project> browseProjectList = [];
        browseProjectList = await BrowseDbRepository().getProjectsByUser(
          currentUser.id,
        );

        // 3. Init existing polygons
        final polygons = await PolygonDbRepository().getPolygonsByUser(
          currentUser.id,
        );

        // 4. Init SLS with business list
        List<SlsWithBusiness> slsWithBusinessList = await BrowseDbRepository()
            .getSlsWithBusinessList(currentUserId: currentUser.id);

        // 5. Init businesses list from the local DB based on the browse project id
        List<TagData> businesses = [];
        if (browseProjectList.isNotEmpty) {
          businesses = await BrowseDbRepository().getBusinessesByBrowseProjects(
            browseProjectList.map((project) => project.id).toList(),
            currentUser.id,
          );
        }

        // 6. Init filter options for project type and sls filter based on the initialized businesses list
        final projectTypesFilterOptions = <ProjectType>[
          ProjectType.marketSwmaps,
          ProjectType.supplementSwmaps,
          ProjectType.supplementMobile,
          ProjectType.sbr,
          ProjectType.agriculture,
          ProjectType.eform,
          ProjectType.other,
        ];

        emit(
          InitializingSuccess(
            data: state.data.copyWith(
              currentUser: currentUser,
              regencies: regencies,
              polygons: polygons,
              slsWithBusinessList: slsWithBusinessList,
              filteredSlsWithBusinessList: slsWithBusinessList,
              businesses: businesses,
              filteredBusinesses:
                  businesses, // Initialize filteredBusinesses with the full list of businesses
              projectTypesFilterOptions: projectTypesFilterOptions,
              slsFilterOptions: _getSlsFilterOptions(businesses),
            ),
          ),
        );
      } catch (e) {
        emit(
          InitializingError(
            errorMessage: e.toString(),
            data: state.data.copyWith(),
          ),
        );
      }
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
                    slsFilterOptions: _getSlsFilterOptions(
                      updatedNearbyBusiness,
                    ),
                    requestedAreas: [
                      ...state.data.requestedAreas,
                      requestedArea,
                    ],
                    // isFirstTimeMapLoading: false,
                  ),
                ),
              );

              // Reset filter when new business inside bounds is fetched
              add(ResetAllFilter());
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
      final browseDbRepository = BrowseDbRepository();
      final polygonDbRepository = PolygonDbRepository();
      final currentUserId = state.data.currentUser?.id ?? '';

      await ApiServerHandler.run(
        action: () async {
          emit(
            BrowseState(
              data: state.data.copyWith(isBusinessBySlsLoading: true),
            ),
          );

          // 1. Check if local data is up-to-date
          final needToDownload = await browseDbRepository
              .needToDownloadBusinessFromServer(event.sls.id, currentUserId);

          // 2. If local data is sufficient, load from DB and return early
          if (!needToDownload) {
            final localBusinesses = await browseDbRepository.getBusinessesBySls(
              event.sls.id,
              currentUserId,
            );

            final mergedBusinesses = List.of(state.data.businesses);
            final existingIds = mergedBusinesses.map((e) => e.remoteId).toSet();
            mergedBusinesses.addAll(
              localBusinesses.where((b) => existingIds.add(b.remoteId)),
            );

            emit(
              BusinessBySlsSuccess(
                centerLocation: LatLng(
                  localBusinesses.first.positionLat,
                  localBusinesses.first.positionLng,
                ),
                data: state.data.copyWith(
                  isBusinessBySlsLoading: false,
                  businesses: mergedBusinesses,
                  slsFilterOptions: _getSlsFilterOptions(mergedBusinesses),
                ),
              ),
            );

            // Reset filter when business by SLS is loaded from local DB
            add(ResetAllFilter());
            return;
          }

          // 3. Fetch businesses from server
          final response = await BrowseRepository().getBusinessesBySls(
            event.sls.id,
          );
          List<TagData> businesses =
              response['businesses'] != null
                  ? List<Map<String, dynamic>>.from(
                    response['businesses'],
                  ).map((data) => TagData.fromServerJson(data)).toList()
                  : [];

          if (businesses.isEmpty) {
            emit(
              NoBusinessInsideBounds(
                message: 'Tidak ada prelist usaha di SLS ${event.sls.name}',
                data: state.data.copyWith(isBusinessBySlsLoading: false),
              ),
            );
            return;
          }

          // 4. Modify the business id to new uuid
          businesses =
              businesses.map((b) => b.copyWith(id: _uuid.v4())).toList();

          // 5. Save users to local DB if not already exist
          await browseDbRepository.insertUniqueUsersFromBusinesses(businesses);

          // 6. Get unique business.project values from the fetched businesses and save to local DB if not already exist
          // Modify the user_id field of the project to be the current user's id before saving to local DB
          // Modify the unique projects id to new uuid
          await browseDbRepository.insertUniqueProjectsFromBusinesses(
            businesses,
            state.data.currentUser,
          );

          // 7. Save the business data to local DB
          await browseDbRepository.insertBusinessesDataBatch(
            businesses,
            currentUserId,
          );

          // 8. Save the polygon to local DB and link it with the current user
          final Sls slsWithPolygon = Sls.fromJson(response['sls']);
          final Polygon? updatedPolygon = slsWithPolygon.polygon;
          bool pairAdded = false;

          if (updatedPolygon != null) {
            await polygonDbRepository.savePolygonWithPoints(updatedPolygon);
            // Check if user-polygon pair already exists before adding
            pairAdded = await polygonDbRepository.addUniqueUserPolygonPair(
              currentUserId,
              updatedPolygon.id,
            );
          }

          // 9. Save SlsWithBusiness to local DB
          final slsWithBusiness = SlsWithBusiness(
            id: _uuid.v4(),
            sls: slsWithPolygon,
            businessCount: businesses.length,
            user: state.data.currentUser!,
          );
          final slsWithBusinessCreated = await browseDbRepository
              .createSlsWithBusiness(slsWithBusiness);

          // 10. Update businesses list in state, ensuring no duplicates
          final mergedBusinesses = List.of(state.data.businesses);
          final existingIds = mergedBusinesses.map((e) => e.remoteId).toSet();
          mergedBusinesses.addAll(
            businesses.where((b) => existingIds.add(b.remoteId)),
          );

          emit(
            BusinessBySlsSuccess(
              centerLocation: LatLng(
                businesses.first.positionLat,
                businesses.first.positionLng,
              ),
              data: state.data.copyWith(
                isBusinessBySlsLoading: false,
                businesses: mergedBusinesses,
                slsFilterOptions: _getSlsFilterOptions(mergedBusinesses),
                polygons:
                    pairAdded
                        ? [...state.data.polygons, updatedPolygon!]
                        : state.data.polygons,
                slsWithBusinessList:
                    slsWithBusinessCreated
                        ? [...state.data.slsWithBusinessList, slsWithBusiness]
                        : state.data.slsWithBusinessList,
                filteredSlsWithBusinessList:
                    slsWithBusinessCreated
                        ? [...state.data.slsWithBusinessList, slsWithBusiness]
                        : state.data.slsWithBusinessList,
              ),
            ),
          );
          // Reset filter when business by SLS is loaded from local DB
          add(ResetAllFilter());
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

    on<SetSlsWithBusinessSidebarOpen>((event, emit) {
      final newDataState = state.data.copyWith(
        isSlsWithBusinessSidebarOpen: event.isOpen,
      );
      if (event.isOpen) {
        emit(SlsWithBusinessSidebarOpened(data: newDataState));
      } else {
        emit(SlsWithBusinessSidebarClosed(data: newDataState));
      }
    });

    on<UpdatePolygon>((event, emit) async {
      emit(BrowseState(data: state.data.copyWith(isLoadingPolygon: true)));
      final polygons = await PolygonDbRepository().getPolygonsByUser(
        state.data.currentUser?.id ?? '',
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
          data: state.data.copyWith(
            isPolygonSideBarOpen: false,
            isSlsWithBusinessSidebarOpen: false,
          ),
        ),
      );
    });

    on<DeletePolygon>((event, emit) async {
      emit(BrowseState(data: state.data.copyWith(isDeletingPolygon: true)));
      await PolygonDbRepository().removeUserPolygonPair(
        state.data.currentUser?.id ?? '',
        event.polygon.id,
      );
      final polygons = await PolygonDbRepository().getPolygonsByUser(
        state.data.currentUser?.id ?? '',
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

    on<DeleteSlsWithBusiness>((event, emit) async {
      emit(
        BrowseState(data: state.data.copyWith(isDeletingSlsWithBusiness: true)),
      );

      await BrowseDbRepository().deleteSlsWithBusiness(
        event.slsWithBusiness.id,
      );

      List<SlsWithBusiness> updatedSlsWithBusinessList =
          state.data.slsWithBusinessList
              .where(
                (slsWithBusiness) =>
                    slsWithBusiness.id != event.slsWithBusiness.id,
              )
              .toList();

      await PolygonDbRepository().removeUserPolygonPair(
        state.data.currentUser?.id ?? '',
        event.slsWithBusiness.sls.polygon?.id ?? event.slsWithBusiness.sls.id,
      );

      await BrowseDbRepository().deleteBusinessesBySlsId(
        event.slsWithBusiness.sls.id,
        state.data.currentUser?.id ?? '',
      );

      List<Polygon> updatedPolygons =
          state.data.polygons
              .where(
                (polygon) =>
                    polygon.id !=
                    (event.slsWithBusiness.sls.polygon?.id ??
                        event.slsWithBusiness.sls.id),
              )
              .toList();

      List<TagData> updatedBusinesses =
          state.data.businesses
              .where(
                (business) => business.sls?.id != event.slsWithBusiness.sls.id,
              )
              .toList();

      emit(
        SlsWithBusinessDeleted(
          data: state.data.copyWith(
            slsWithBusinessList: updatedSlsWithBusinessList,
            filteredSlsWithBusinessList: updatedSlsWithBusinessList,
            polygons: updatedPolygons,
            isDeletingSlsWithBusiness: false,
            businesses: updatedBusinesses,
          ),
        ),
      );
    });

    on<SetBrowseSideBarOpen>((event, emit) {
      final newDataState = state.data.copyWith(
        isBrowseSideBarOpen: event.isOpen,
        // filteredBusinesses:
        //     event.isOpen
        //         ? state.data.businesses
        //         : state.data.filteredBusinesses,
        // resetAllFilter: event.isOpen,
      );
      if (event.isOpen) {
        emit(BrowseSideBarOpened(data: newDataState));
      } else {
        emit(BrowseSideBarClosed(data: newDataState));
      }
    });

    on<ResetAllFilter>((event, emit) {
      emit(
        AllFilterCleared(
          data: state.data.copyWith(
            resetAllFilter: true,
            filteredBusinesses: state.data.businesses,
          ),
        ),
      );
    });

    on<SearchBusiness>((event, emit) {
      final newQuery = event.query;
      final filtered = _applyFilters(
        allTags: state.data.businesses,
        query: newQuery,
        projectType: state.data.selectedProjectTypeFilter,
        sls: state.data.selectedSlsFilter,
      );

      final newDataState = state.data.copyWith(
        filteredBusinesses: filtered,
        searchQuery: newQuery,
        resetSearchQuery: event.reset ?? false,
      );
      if (event.reset ?? false) {
        emit(SearchQueryCleared(data: newDataState));
      } else {
        emit(BrowseState(data: newDataState));
      }
    });

    on<FilterBusinessByProjectType>((event, emit) {
      final selectedProjectType = event.projectType;
      final filtered = _applyFilters(
        allTags: state.data.businesses,
        query: state.data.searchQuery,
        projectType: selectedProjectType,
        sls: state.data.selectedSlsFilter,
      );

      emit(
        BrowseState(
          data: state.data.copyWith(
            filteredBusinesses: filtered,
            selectedProjectTypeFilter: selectedProjectType,
            resetProjectTypeFilter: event.reset ?? false,
          ),
        ),
      );
    });

    on<FilterBusinessBySls>((event, emit) {
      final selectedSls = event.sls;
      final filtered = _applyFilters(
        allTags: state.data.businesses,
        query: state.data.searchQuery,
        projectType: state.data.selectedProjectTypeFilter,
        sls: selectedSls,
      );

      emit(
        BrowseState(
          data: state.data.copyWith(
            filteredBusinesses: filtered,
            selectedSlsFilter: selectedSls,
            resetSlsFilter: event.reset ?? false,
          ),
        ),
      );
    });

    on<SelectBusiness>((event, emit) {
      emit(
        BusinessSelected(
          data: state.data.copyWith(selectedBusinesses: [event.business]),
        ),
      );
    });

    on<ClearBrowseSelection>((event, emit) {
      emit(BrowseState(data: state.data.copyWith(selectedBusinesses: [])));
    });

    on<SearchSlsWithBusiness>((event, emit) {
      final newQuery = event.query;

      final filtered =
          (newQuery == null || newQuery.trim().isEmpty)
              ? state.data.slsWithBusinessList
              : state.data.slsWithBusinessList.where((slsWithBusiness) {
                final lowerQuery = newQuery.toLowerCase();
                final sls = slsWithBusiness.sls;
                return sls.name.toLowerCase().contains(lowerQuery) ||
                    sls.longCode.toLowerCase().contains(lowerQuery) ||
                    (sls.village?.name.toLowerCase().contains(lowerQuery) ??
                        false) ||
                    (sls.village?.subdistrict?.name.toLowerCase().contains(
                          lowerQuery,
                        ) ??
                        false) ||
                    (sls.village?.subdistrict?.regency?.name
                            .toLowerCase()
                            .contains(lowerQuery) ??
                        false);
              }).toList();

      final newDataState = state.data.copyWith(
        filteredSlsWithBusinessList: filtered,
        slsWithBusinessSearchQuery: newQuery,
        resetSlsWithBusinessSearchQuery: event.reset ?? false,
      );
      if (event.reset ?? false) {
        emit(SearchSlsWithBusinessQueryCleared(data: newDataState));
      } else {
        emit(BrowseState(data: newDataState));
      }
    });
  }

  List<Sls> _getSlsFilterOptions(List<TagData> businesses) {
    return businesses
        .where((business) => business.sls != null)
        .map((business) => business.sls!)
        .toSet()
        .toList()
      ..sort((a, b) => a.longCode.compareTo(b.longCode));
  }

  List<TagData> _applyFilters({
    required List<TagData> allTags,
    required String? query,
    required ProjectType? projectType,
    required Sls? sls,
  }) {
    final normalizedQuery = query?.trim().toLowerCase();

    // No filters applied → return all
    if ((normalizedQuery == null || normalizedQuery.isEmpty) &&
        projectType == null &&
        sls == null) {
      return allTags;
    }

    return allTags.where((tag) {
      final matchesQuery =
          normalizedQuery == null ||
          normalizedQuery.isEmpty ||
          tag.businessName.toLowerCase().contains(normalizedQuery) ||
          (tag.businessOwner?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (tag.businessAddress?.toLowerCase().contains(normalizedQuery) ??
              false) ||
          (tag.description?.toLowerCase().contains(normalizedQuery) ?? false);

      final matchesProjectType =
          projectType == null || tag.project.type.key == projectType.key;

      final matchesSls = sls == null || tag.sls?.id == sls.id;

      return matchesQuery && matchesProjectType && matchesSls;
    }).toList();
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
