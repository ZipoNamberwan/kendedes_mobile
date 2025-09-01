import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kendedes_mobile/classes/api_server_handler.dart';
import 'package:kendedes_mobile/classes/helpers.dart';
import 'package:kendedes_mobile/classes/map_config.dart';
import 'package:kendedes_mobile/classes/repositories/auth_repository.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/polygon_db_repository.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/tagging_db_repository.dart';
import 'package:kendedes_mobile/classes/repositories/tagging_repository.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/models/requested_area.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:kendedes_mobile/models/user.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import 'tagging_event.dart';
import 'tagging_state.dart';

class TaggingBloc extends Bloc<TaggingEvent, TaggingState> {
  final Uuid _uuid = const Uuid();

  TaggingBloc() : super(InitializingStarted()) {
    on<InitTag>((event, emit) async {
      emit(InitializingStarted());
      try {
        // Open the Hive box for tag data
        final List<TagData> tags = await TaggingDbRepository()
            .getAllByProjectId(event.project.id);

        final User currentUser = AuthRepository().getUser();

        final polygons = await PolygonDbRepository().getPolygonsForProject(
          event.project.id,
        );
        // Emit success state with initial data
        emit(
          InitializingSuccess(
            data: state.data.copyWith(
              project: event.project,
              tags: tags,
              currentUser: currentUser,
              polygons: polygons,
            ),
          ),
        );

        // add(GetCurrentLocation());
      } catch (e) {
        emit(
          InitializingError(
            errorMessage: e.toString(),
            data: state.data.copyWith(),
          ),
        );
      }
    });

    on<UpdateZoom>((event, emit) {
      emit(
        TaggingState(data: state.data.copyWith(currentZoom: event.zoomLevel)),
      );
    });

    on<UpdateRotation>((event, emit) {
      emit(TaggingState(data: state.data.copyWith(rotation: event.rotation)));
    });

    on<GetCurrentLocation>((event, emit) async {
      emit(
        TaggingState(data: state.data.copyWith(isLoadingCurrentLocation: true)),
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
          TagError(
            errorMessage: e.toString(),
            data: state.data.copyWith(isLoadingCurrentLocation: false),
          ),
        );
      }
    });

    on<DeleteTag>((event, emit) async {
      try {
        await ApiServerHandler.run(
          action: () async {
            emit(
              TagDeletedLoading(data: state.data.copyWith(isDeletingTag: true)),
            );

            await TaggingRepository().deleteTagging(event.tagData.id);
            await TaggingDbRepository().deleteById(event.tagData.id);
            final updatedTags = List<TagData>.from(state.data.tags)
              ..removeWhere((tag) => tag.id == event.tagData.id);

            // Also remove from selectedTags if present
            final updatedSelectedTags = List<TagData>.from(
              state.data.selectedTags,
            )..removeWhere((tag) => tag.id == event.tagData.id);

            emit(
              TagDeletedSuccess(
                successMessage: 'Tagging berhasil dihapus',
                data: state.data.copyWith(
                  tags: updatedTags,
                  selectedTags: updatedSelectedTags,
                  isDeletingTag: false,
                ),
              ),
            );
          },
          onLoginExpired: (e) {
            emit(TokenExpired(data: state.data.copyWith(isDeletingTag: false)));
            return;
          },
          onDataProviderError: (e) {
            emit(
              TagDeletedError(
                errorMessage: e.message,
                data: state.data.copyWith(isDeletingTag: false),
              ),
            );
            return;
          },
          onOtherError: (e) {
            emit(
              TagDeletedError(
                errorMessage: e.toString(),
                data: state.data.copyWith(isDeletingTag: false),
              ),
            );
            return;
          },
        );
      } catch (e) {
        emit(
          TagDeletedError(
            errorMessage: e.toString(),
            data: state.data.copyWith(isDeletingTag: false),
          ),
        );
        return;
      }
    });

    on<DeleteSelectedTags>((event, emit) async {
      try {
        await ApiServerHandler.run(
          action: () async {
            emit(
              DeleteMultipleTagsLoading(
                data: state.data.copyWith(isDeletingTag: true),
              ),
            );

            final deletedTags = state.data.selectedTags.where((tag) {
              return tag.project.id == state.data.project.id;
            });
            final deletedTagIds = deletedTags.map((tag) => tag.id).toList();

            final result = await TaggingRepository().deleteMultipleTags(
              deletedTagIds,
            );

            if (result) {
              await TaggingDbRepository().deleteByIds(deletedTagIds);

              emit(
                DeleteMultipleTagsSuccess(
                  successMessage:
                      'Berhasil menghapus ${deletedTags.length} tagging terpilih',
                  data: state.data.copyWith(
                    tags:
                        state.data.tags
                            .where((tag) => !deletedTags.contains(tag))
                            .toList(),
                    filteredTags:
                        state.data.filteredTags
                            .where((tag) => !deletedTags.contains(tag))
                            .toList(),
                    selectedTags: [],
                    isDeletingTag: false,
                  ),
                ),
              );
            } else {
              emit(
                DeleteMultipleTagsError(
                  errorMessage: 'Gagal menghapus tagging',
                  data: state.data.copyWith(isDeletingTag: false),
                ),
              );
            }
          },
          onLoginExpired: (e) {
            emit(TokenExpired(data: state.data.copyWith(isDeletingTag: false)));
          },
          onDataProviderError: (e) {
            emit(
              DeleteMultipleTagsError(
                errorMessage: e.message,
                data: state.data.copyWith(isDeletingTag: false),
              ),
            );
          },
          onOtherError: (e) {
            emit(
              DeleteMultipleTagsError(
                errorMessage: e.toString(),
                data: state.data.copyWith(isDeletingTag: false),
              ),
            );
          },
        );
      } catch (e) {
        emit(
          DeleteMultipleTagsError(
            errorMessage: e.toString(),
            data: state.data.copyWith(isDeletingTag: false),
          ),
        );
      }
    });

    on<SelectTag>((event, emit) {
      emit(
        TagSelected(data: state.data.copyWith(selectedTags: [event.tagData])),
      );
    });

    on<UploadSelectedTags>((event, emit) async {
      await ApiServerHandler.run(
        action: () async {
          emit(
            UploadMultipleTagsLoading(
              data: state.data.copyWith(isUploadingMultipleTags: true),
            ),
          );

          List<TagData> uploadedTags = [];
          if (event.uploadAll) {
            uploadedTags =
                state.data.tags.where((tag) {
                  return tag.project.id == state.data.project.id &&
                      !tag.hasSentToServer;
                }).toList();
          } else {
            uploadedTags =
                state.data.selectedTags.where((tag) {
                  return tag.project.id == state.data.project.id &&
                      !tag.hasSentToServer;
                }).toList();
          }

          final User user = AuthRepository().getUser();

          uploadedTags =
              uploadedTags.map((tag) {
                return tag.copyWith(user: user);
              }).toList();

          final ids = await TaggingRepository().uploadMultipleTags(
            uploadedTags.toList(),
          );

          if (ids.isNotEmpty) {
            // Update local Hive box
            for (final tag in uploadedTags) {
              if (ids.contains(tag.id)) {
                final updatedTag = tag.copyWith(
                  hasChanged: false,
                  hasSentToServer: true,
                  user: user,
                );
                //TODO: can be optimized by using a batch operation
                await TaggingDbRepository().insertOrUpdate(updatedTag);
              }
            }

            // Update tags list
            final updatedTags =
                state.data.tags.map((tag) {
                  return ids.contains(tag.id)
                      ? tag.copyWith(hasChanged: false, hasSentToServer: true)
                      : tag;
                }).toList();

            emit(
              UploadMultipleTagsSuccess(
                successMessage: 'Tagging berhasil diupload',
                data: state.data.copyWith(
                  tags: updatedTags,
                  selectedTags: [],
                  isUploadingMultipleTags: false,
                ),
              ),
            );
          } else {
            emit(
              UploadMultipleTagsError(
                errorMessage: 'Tidak ada tagging yang berhasil diupload',
                data: state.data.copyWith(isUploadingMultipleTags: false),
              ),
            );
          }
        },
        onLoginExpired: (e) {
          emit(
            TokenExpired(
              data: state.data.copyWith(isUploadingMultipleTags: false),
            ),
          );
        },
        onDataProviderError: (e) {
          emit(
            UploadMultipleTagsError(
              errorMessage: e.message,
              data: state.data.copyWith(isUploadingMultipleTags: false),
            ),
          );
        },
        onOtherError: (e) {
          emit(
            UploadMultipleTagsError(
              errorMessage: e.toString(),
              data: state.data.copyWith(isUploadingMultipleTags: false),
            ),
          );
        },
      );
    });

    on<AddTagToSelection>((event, emit) {
      // Check if tag is already selected
      final isAlreadySelected = state.data.selectedTags.any(
        (tag) => tag.id == event.tagData.id,
      );

      if (!isAlreadySelected) {
        emit(
          TaggingState(
            data: state.data.copyWith(
              selectedTags: [...state.data.selectedTags, event.tagData],
            ),
          ),
        );
      }
    });

    on<RemoveTagFromSelection>((event, emit) {
      emit(
        TaggingState(
          data: state.data.copyWith(
            selectedTags:
                state.data.selectedTags
                    .where((tag) => tag.id != event.tagData.id)
                    .toList(),
          ),
        ),
      );
    });

    on<ToggleMultiSelectMode>((event, emit) {
      emit(
        TaggingState(
          data: state.data.copyWith(
            isMultiSelectMode: !state.data.isMultiSelectMode,
          ),
        ),
      );
    });

    on<ClearTagSelection>((event, emit) {
      emit(TaggingState(data: state.data.copyWith(selectedTags: [])));
    });

    on<UpdateCurrentLocation>((event, emit) async {
      emit(
        TaggingState(
          data: state.data.copyWith(currentLocation: event.newPosition),
        ),
      );
    });

    on<EditForm>((event, emit) {
      emit(TaggingState(data: state.data.copyWith(isForceTagging: false)));

      final TagData tagData = event.tagData;
      final formFields = {
        'id': TaggingFormFieldState<String?>(value: tagData.id),
        'name': TaggingFormFieldState<String>(value: tagData.businessName),
        'owner': TaggingFormFieldState<String?>(value: tagData.businessOwner),
        'address': TaggingFormFieldState<String?>(
          value: tagData.businessAddress,
        ),
        'building': TaggingFormFieldState<BuildingStatus>(
          value: tagData.buildingStatus,
        ),
        'description': TaggingFormFieldState<String>(
          value: tagData.description,
        ),
        'sector': TaggingFormFieldState<Sector>(value: tagData.sector),
        'note': TaggingFormFieldState<String?>(value: tagData.note),
        'positionLat': TaggingFormFieldState<double>(
          value: tagData.positionLat,
        ),
        'positionLng': TaggingFormFieldState<double>(
          value: tagData.positionLng,
        ),
      };

      emit(EditFormShown(data: state.data.copyWith(formFields: formFields)));
    });

    on<SetTaggingFormField>((event, emit) {
      final updatedFormFields = _updateFieldValue(
        state.data.formFields,
        event.key,
        event.value,
      );
      emit(
        TaggingState(data: state.data.copyWith(formFields: updatedFormFields)),
      );
    });

    on<SaveCreateForm>((event, emit) async {
      emit(TaggingState(data: state.data.copyWith(isSubmitting: true)));

      final formFields = state.data.formFields;
      final validationResult = _validateForm(formFields);

      if (validationResult.hasErrors) {
        emit(
          TaggingState(
            data: state.data.copyWith(
              formFields: validationResult.updatedFields,
              isSubmitting: false,
            ),
          ),
        );
        return;
      }

      try {
        final User user = AuthRepository().getUser();

        final newTag = TagData(
          id: _uuid.v4(),
          positionLat: formFields['positionLat']?.value as double,
          positionLng: formFields['positionLng']?.value as double,
          initialPositionLat: formFields['positionLat']?.value as double,
          initialPositionLng: formFields['positionLng']?.value as double,
          hasChanged: true,
          hasSentToServer: false,
          type: TagType.auto,
          isDeleted: false,
          businessName: formFields['name']?.value as String,
          businessOwner: formFields['owner']?.value as String?,
          businessAddress: formFields['address']?.value as String?,
          buildingStatus: formFields['building']?.value as BuildingStatus,
          description: formFields['description']?.value as String,
          sector: formFields['sector']?.value as Sector,
          note: formFields['note']?.value as String?,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          project: state.data.project,
          user: user,
        );

        // 🔐 Save to SQL Lite
        await TaggingDbRepository().insertOrUpdate(newTag);

        final updatedTags = [...state.data.tags, newTag];

        emit(
          SaveFormSuccess(
            newTag: newTag,
            successMessage: 'Tagging berhasil disimpan',
            data: state.data.copyWith(
              tags: updatedTags,
              isSubmitting: false,
              formFields: validationResult.updatedFields,
            ),
          ),
        );

        await ApiServerHandler.run(
          action: () async {
            await TaggingRepository().storeTagging(newTag);
            final savedTag = newTag.copyWith(
              hasChanged: false,
              hasSentToServer: true,
            );
            await TaggingDbRepository().insertOrUpdate(savedTag);

            final updatedTags =
                state.data.tags
                    .map((tag) => tag.id == savedTag.id ? savedTag : tag)
                    .toList();
            emit(
              TaggingState(
                data: state.data.copyWith(
                  tags: updatedTags,
                  filteredTags: updatedTags,
                ),
              ),
            );
          },
          onLoginExpired: (e) {},
          onDataProviderError: (e) {},
          onOtherError: (e) {},
        );
      } catch (e) {
        emit(
          SaveFormError(
            errorMessage: e.toString(),
            data: state.data.copyWith(isSubmitting: false),
          ),
        );
      }
    });

    on<SaveEditForm>((event, emit) async {
      emit(TaggingState(data: state.data.copyWith(isSubmitting: true)));

      final formFields = state.data.formFields;
      final validationResult = _validateForm(formFields);

      if (validationResult.hasErrors) {
        emit(
          TaggingState(
            data: state.data.copyWith(
              formFields: validationResult.updatedFields,
              isSubmitting: false,
            ),
          ),
        );
        return;
      }

      try {
        final User user = AuthRepository().getUser();

        final updatedTag = TagData(
          id: event.tagData.id,
          positionLat: formFields['positionLat']!.value as double,
          positionLng: formFields['positionLng']!.value as double,
          initialPositionLat: event.tagData.initialPositionLat,
          initialPositionLng: event.tagData.initialPositionLng,
          hasChanged: true,
          hasSentToServer: false,
          type: TagType.auto,
          isDeleted: false,
          businessName: formFields['name']?.value as String,
          businessOwner: formFields['owner']?.value as String?,
          businessAddress: formFields['address']?.value as String?,
          buildingStatus: formFields['building']?.value as BuildingStatus,
          description: formFields['description']?.value as String,
          sector: formFields['sector']?.value as Sector,
          note: formFields['note']?.value as String?,
          createdAt: event.tagData.createdAt,
          updatedAt: DateTime.now(),
          project: state.data.project,
          user: user,
        );

        // 🔐 Save to db
        await TaggingDbRepository().insertOrUpdate(updatedTag);

        // Update tags list
        final updatedTags =
            state.data.tags
                .map((tag) => tag.id == event.tagData.id ? updatedTag : tag)
                .toList();
        // Update selected tags if the edited tag is selected
        final updatedSelectedTags =
            state.data.selectedTags
                .map((tag) => tag.id == event.tagData.id ? updatedTag : tag)
                .toList();

        emit(
          SaveFormSuccess(
            newTag: updatedTag,
            successMessage: 'Tagging berhasil disimpan',
            data: state.data.copyWith(
              tags: updatedTags,
              selectedTags: updatedSelectedTags,
              isSubmitting: false,
              formFields: validationResult.updatedFields,
            ),
          ),
        );

        await ApiServerHandler.run(
          action: () async {
            await TaggingRepository().updateTagging(updatedTag);
            final savedTag = updatedTag.copyWith(
              hasChanged: false,
              hasSentToServer: true,
            );
            await TaggingDbRepository().insertOrUpdate(savedTag);

            final updatedTags =
                state.data.tags
                    .map((tag) => tag.id == savedTag.id ? savedTag : tag)
                    .toList();

            final updatedSelectedTags =
                state.data.selectedTags
                    .map((tag) => tag.id == savedTag.id ? savedTag : tag)
                    .toList();

            emit(
              TaggingState(
                data: state.data.copyWith(
                  tags: updatedTags,
                  selectedTags: updatedSelectedTags,
                  filteredTags: updatedTags,
                ),
              ),
            );
          },
          onLoginExpired: (e) {},
          onDataProviderError: (e) {},
          onOtherError: (e) {},
        );
      } catch (e) {
        emit(
          SaveFormError(
            errorMessage: e.toString(),
            data: state.data.copyWith(isSubmitting: false),
          ),
        );
      }
    });

    on<RecordTagLocation>((event, emit) async {
      emit(
        TaggingState(
          data: state.data.copyWith(isLoadingTag: true, resetForm: true),
        ),
      );

      try {
        Position position = await _getCurrentPosition();

        if (position.isMocked) {
          emit(
            MockupLocationDetected(
              data: state.data.copyWith(isLoadingTag: false),
            ),
          );
          return;
        }

        if (!event.forceTagging) {
          final bool alreadyRequested = _hasAlreadyRequestedArea(
            position: LatLng(position.latitude, position.longitude),
            requestedAreas: state.data.requestedAreas,
          );

          if (!alreadyRequested) {
            emit(
              AreaNotRequestedNotification(
                recordedLocation: LatLng(position.latitude, position.longitude),
                data: state.data.copyWith(isLoadingTag: false),
              ),
            );
            return;
          }
        }

        final updatedFormFields = {
          ...state.data.formFields,
          'positionLat': state.data.formFields['positionLat']!.copyWith(
            value: position.latitude,
          ),
          'positionLng': state.data.formFields['positionLng']!.copyWith(
            value: position.longitude,
          ),
        };

        emit(
          RecordedLocation(
            recordedLocation: LatLng(position.latitude, position.longitude),
            data: state.data.copyWith(
              isLoadingTag: false,
              formFields: {...updatedFormFields},
              isForceTagging: event.forceTagging,
            ),
          ),
        );
      } catch (e) {
        emit(
          TagError(
            errorMessage: e.toString(),
            data: state.data.copyWith(isLoadingTag: false),
          ),
        );
      }
    });

    on<SetTaggingSideBarOpen>((event, emit) {
      final newDataState = state.data.copyWith(
        isTaggingSideBarOpen: event.isOpen,
        filteredTags: event.isOpen ? state.data.tags : state.data.filteredTags,
        resetAllFilter: event.isOpen,
        isMultiSelectMode: false,
      );
      if (event.isOpen) {
        emit(TaggingSideBarOpened(data: newDataState));
      } else {
        emit(TaggingSideBarClosed(data: newDataState));
      }
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

    on<ResetAllFilter>((event, emit) {
      emit(
        AllFilterCleared(
          data: state.data.copyWith(
            resetAllFilter: true,
            filteredTags: state.data.tags,
          ),
        ),
      );
    });

    on<SearchTagging>((event, emit) {
      final newQuery = event.query;
      final filtered = _applyFilters(
        allTags: state.data.tags,
        query: newQuery,
        sector: state.data.selectedSectorFilter,
        projectType: state.data.selectedProjectTypeFilter,
        isFilterCurrentProject: state.data.isFilterCurrentProject,
        isFilterSentToServer: state.data.isFilterSentToServer,
        currentProject: state.data.project,
      );

      final newDataState = state.data.copyWith(
        filteredTags: filtered,
        searchQuery: newQuery,
        resetSearchQuery: event.reset ?? false,
      );
      if (event.reset ?? false) {
        emit(SearchQueryCleared(data: newDataState));
      } else {
        emit(TaggingState(data: newDataState));
      }
    });

    on<FilterTaggingBySector>((event, emit) {
      final selectedSector = event.sector;
      final filtered = _applyFilters(
        allTags: state.data.tags,
        query: state.data.searchQuery,
        sector: selectedSector,
        projectType: state.data.selectedProjectTypeFilter,
        isFilterCurrentProject: state.data.isFilterCurrentProject,
        isFilterSentToServer: state.data.isFilterSentToServer,
        currentProject: state.data.project,
      );

      emit(
        TaggingState(
          data: state.data.copyWith(
            filteredTags: filtered,
            selectedSectorFilter: selectedSector,
            resetSectorFilter: event.reset ?? false,
          ),
        ),
      );
    });

    on<FilterTaggingByProjectType>((event, emit) {
      final selectedProjectType = event.projectType;
      final filtered = _applyFilters(
        allTags: state.data.tags,
        query: state.data.searchQuery,
        sector: state.data.selectedSectorFilter,
        projectType: selectedProjectType,
        isFilterCurrentProject: state.data.isFilterCurrentProject,
        isFilterSentToServer: state.data.isFilterSentToServer,
        currentProject: state.data.project,
      );

      emit(
        TaggingState(
          data: state.data.copyWith(
            filteredTags: filtered,
            selectedProjectTypeFilter: selectedProjectType,
            resetProjectTypeFilter: event.reset ?? false,
          ),
        ),
      );
    });

    on<FilterCurrentProject>((event, emit) {
      final filtered = _applyFilters(
        allTags: state.data.tags,
        query: state.data.searchQuery,
        sector: state.data.selectedSectorFilter,
        projectType: state.data.selectedProjectTypeFilter,
        isFilterCurrentProject: event.isFilterCurrentProject,
        isFilterSentToServer: state.data.isFilterSentToServer,
        currentProject: state.data.project,
      );

      emit(
        TaggingState(
          data: state.data.copyWith(
            filteredTags: filtered,
            isFilterCurrentProject: event.isFilterCurrentProject,
          ),
        ),
      );
    });

    on<FilterHasSentToServer>((event, emit) {
      final filtered = _applyFilters(
        allTags: state.data.tags,
        query: state.data.searchQuery,
        sector: state.data.selectedSectorFilter,
        projectType: state.data.selectedProjectTypeFilter,
        isFilterCurrentProject: state.data.isFilterCurrentProject,
        isFilterSentToServer: event.isFilterSentToServer,
        currentProject: state.data.project,
      );

      emit(
        TaggingState(
          data: state.data.copyWith(
            filteredTags: filtered,
            isFilterSentToServer: event.isFilterSentToServer,
          ),
        ),
      );
    });

    on<SelectLabelType>((event, emit) {
      emit(
        TaggingState(
          data: state.data.copyWith(selectedLabelType: event.labelTypeKey),
        ),
      );
    });

    on<SelectMapType>((event, emit) {
      emit(
        TaggingState(
          data: state.data.copyWith(selectedMapType: event.mapTypeKey),
        ),
      );
    });

    on<CloseProject>((event, emit) {
      // state.data.tagDataBox?.close();
    });

    on<UpdateVisibleMapBounds>((event, emit) {
      emit(
        TaggingState(
          data: state.data.copyWith(
            northEastCorner: event.ne,
            southWestCorner: event.sw,
          ),
        ),
      );
      if (state.data.isFirstTimeMapLoading &&
          state.data.currentLocation != null) {
        add(GetTaggingInsideBounds());
      }
    });

    on<GetTaggingInsideBounds>((event, emit) async {
      if (state.data.currentZoom <
          MapConfig.minimumZoomToGetTaggingInsideBounds) {
        emit(
          ZoomLevelNotification(
            message:
                'Minimum zoom level untuk mendapatkan data tagging adalah '
                '${MapConfig.minimumZoomToGetTaggingInsideBounds}. Apakah akan memperbesar zoom?',
            data: state.data.copyWith(isTaggingInsideBoundsLoading: false),
          ),
        );
        return;
      } else {
        await ApiServerHandler.run(
          action: () async {
            emit(
              TaggingState(
                data: state.data.copyWith(
                  isTaggingInsideBoundsLoading: true,
                  isFirstTimeMapLoading: false,
                ),
              ),
            );

            final ne = state.data.northEastCorner;
            final sw = state.data.southWestCorner;

            final tags = await TaggingRepository().getTaggingInBox(
              minLat: sw?.latitude ?? 0.0,
              minLng: sw?.longitude ?? 0.0,
              maxLat: ne?.latitude ?? 0.0,
              maxLng: ne?.longitude ?? 0.0,
            );

            final requestedArea = RequestedArea(
              northeast: ne ?? const LatLng(0, 0),
              southwest: sw ?? const LatLng(0, 0),
            );

            if (tags.isEmpty) {
              emit(
                NoTaggingInsideBounds(
                  message: 'Belum ada tagging di area ini',
                  data: state.data.copyWith(
                    isTaggingInsideBoundsLoading: false,
                    requestedAreas: [
                      ...state.data.requestedAreas,
                      requestedArea,
                    ],
                  ),
                ),
              );
            } else {
              // Create a copy of the current tags list
              final updatedNearByTags = List.of(state.data.tags);

              // Use a Set for efficient duplicate checks
              final existingIds = updatedNearByTags.map((e) => e.id).toSet();

              // Add only new tags
              updatedNearByTags.addAll(
                tags.where((tag) => !existingIds.contains(tag.id)),
              );

              emit(
                TaggingState(
                  data: state.data.copyWith(
                    isTaggingInsideBoundsLoading: false,
                    tags: updatedNearByTags,
                    requestedAreas: [
                      ...state.data.requestedAreas,
                      requestedArea,
                    ],
                  ),
                ),
              );
            }
          },
          onLoginExpired: (e) {
            emit(
              TokenExpired(
                data: state.data.copyWith(
                  isTaggingInsideBoundsLoading: false,
                  isTaggingInsideBoundsError: true,
                ),
              ),
            );
          },
          onDataProviderError: (e) {
            emit(
              TaggingInsideBoundsFailed(
                errorMessage: e.message,
                data: state.data.copyWith(
                  isTaggingInsideBoundsLoading: false,
                  isTaggingInsideBoundsError: true,
                ),
              ),
            );
          },
          onOtherError: (e) {
            emit(
              TaggingInsideBoundsFailed(
                errorMessage: e.toString(),
                data: state.data.copyWith(
                  isTaggingInsideBoundsLoading: false,
                  isTaggingInsideBoundsError: true,
                ),
              ),
            );
          },
        );
      }
    });

    // Move mode logic
    on<StartMoveMode>((event, emit) {
      emit(
        TaggingState(
          data: state.data.copyWith(
            isMoveMode: true,
            originalMovedTag: event.tagData,
          ),
        ),
      );
    });

    on<SaveMoveTag>((event, emit) async {
      try {
        emit(TaggingState(data: state.data));

        final User user = AuthRepository().getUser();

        final updatedTag = state.data.newMovedTag?.copyWith(
          user: user,
          hasChanged: true,
          hasSentToServer: false,
          updatedAt: DateTime.now(),
        );

        if (updatedTag == null) {
          throw Exception('Anda belum memilih lokasi baru');
        }

        // save new moved tag to database
        await TaggingDbRepository().insertOrUpdate(updatedTag);
        // Update the tag in the list
        final updatedTags =
            state.data.tags.map((tag) {
              return tag.id == updatedTag.id ? updatedTag : tag;
            }).toList();
        // Update the selected tags if the moved tag is selected
        final updatedSelectedTags =
            state.data.selectedTags.map((tag) {
              return tag.id == updatedTag.id ? updatedTag : tag;
            }).toList();

        emit(
          MoveTagSuccess(
            data: state.data.copyWith(
              tags: updatedTags,
              selectedTags: updatedSelectedTags,
              isMoveMode: false,
              clearOriginalMovedTag: true,
              clearNewMovedTag: true,
            ),
          ),
        );

        await ApiServerHandler.run(
          action: () async {
            await TaggingRepository().updateTagging(updatedTag);
            final savedTag = updatedTag.copyWith(
              hasChanged: false,
              hasSentToServer: true,
            );
            await TaggingDbRepository().insertOrUpdate(savedTag);

            final updatedTags =
                state.data.tags
                    .map((tag) => tag.id == savedTag.id ? savedTag : tag)
                    .toList();

            final updatedSelectedTags =
                state.data.selectedTags
                    .map((tag) => tag.id == savedTag.id ? savedTag : tag)
                    .toList();

            emit(
              TaggingState(
                data: state.data.copyWith(
                  tags: updatedTags,
                  selectedTags: updatedSelectedTags,
                  filteredTags: updatedTags,
                ),
              ),
            );
          },
          onLoginExpired: (e) {},
          onDataProviderError: (e) {},
          onOtherError: (e) {},
        );
      } catch (e) {
        emit(MoveTagError(errorMessage: e.toString(), data: state.data));
      }
    });

    on<MoveTag>((event, emit) {
      final originalTag = state.data.originalMovedTag;
      if (originalTag == null) return;

      // Calculate distance between original position and new position
      final Distance distance = Distance();
      final originalPosition = LatLng(
        originalTag.positionLat,
        originalTag.positionLng,
      );
      final newPosition = event.newPosition;

      final distanceInMeters = distance.as(
        LengthUnit.Meter,
        originalPosition,
        newPosition,
      );

      // Check if the new position is outside the allowed move radius (30m)
      if (distanceInMeters > MapConfig.moveRadius) {
        emit(OutsideMoveRadius(data: state.data.copyWith()));
        return;
      }

      final newMovedTag = originalTag.copyWith(
        positionLat: event.newPosition.latitude,
        positionLng: event.newPosition.longitude,
      );

      emit(TaggingState(data: state.data.copyWith(newMovedTag: newMovedTag)));
    });

    on<CancelMoveMode>((event, emit) {
      emit(
        TaggingState(
          data: state.data.copyWith(
            isMoveMode: false,
            clearOriginalMovedTag: true,
            clearNewMovedTag: true,
          ),
        ),
      );
    });

    on<UpdatePolygon>((event, emit) async {
      emit(TaggingState(data: state.data.copyWith(isLoadingPolygon: true)));
      final polygons = await PolygonDbRepository().getPolygonsForProject(
        state.data.project.id,
      );
      emit(
        TaggingState(
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
      emit(TaggingState(data: state.data.copyWith(isDeletingPolygon: true)));
      await PolygonDbRepository().removeProjectPolygonPair(
        state.data.project.id,
        event.polygon.id,
      );
      final polygons = await PolygonDbRepository().getPolygonsForProject(
        state.data.project.id,
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

  List<TagData> _applyFilters({
    required List<TagData> allTags,
    required String? query,
    required Sector? sector,
    required ProjectType? projectType,
    required bool isFilterCurrentProject,
    required bool isFilterSentToServer,
    required Project currentProject,
  }) {
    final normalizedQuery = query?.trim().toLowerCase();

    // No filters applied → return all
    if ((normalizedQuery == null || normalizedQuery.isEmpty) &&
        sector == null &&
        projectType == null &&
        !isFilterCurrentProject &&
        !isFilterSentToServer) {
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
          tag.description.toLowerCase().contains(normalizedQuery);

      final matchesSector = sector == null || tag.sector?.key == sector.key;

      final matchesProjectType =
          projectType == null || tag.project.type.key == projectType.key;

      final matchesCurrentProject =
          !isFilterCurrentProject || (tag.project.id == currentProject.id);

      final matchesSentToServer =
          !isFilterSentToServer || (!tag.hasSentToServer);

      return matchesQuery &&
          matchesSector &&
          matchesProjectType &&
          matchesCurrentProject &&
          matchesSentToServer;
    }).toList();
  }

  Map<String, TaggingFormFieldState<dynamic>> _updateFieldValue(
    Map<String, TaggingFormFieldState<dynamic>> fields,
    String key,
    dynamic value,
  ) {
    final field = fields[key];

    if (field == null) return fields;

    if (field is TaggingFormFieldState<String>) {
      return {...fields, key: field.copyWith(value: value as String)};
    } else if (field is TaggingFormFieldState<String?>) {
      return {...fields, key: field.copyWith(value: value as String?)};
    } else if (field is TaggingFormFieldState<BuildingStatus>) {
      return {...fields, key: field.copyWith(value: value as BuildingStatus)};
    } else if (field is TaggingFormFieldState<Sector>) {
      return {...fields, key: field.copyWith(value: value as Sector)};
    } else if (field is TaggingFormFieldState<double>) {
      return {...fields, key: field.copyWith(value: value as double)};
    }

    return fields;
  }

  ValidationResult _validateForm(
    Map<String, TaggingFormFieldState<dynamic>> formFields,
  ) {
    Map<String, TaggingFormFieldState<dynamic>> updatedFields = Map.from(
      formFields,
    );
    bool hasErrors = false;

    // Validate name
    final name = formFields['name']?.value as String? ?? '';
    if (name.isEmpty) {
      updatedFields['name'] = updatedFields['name']!.copyWith(
        error: 'Nama Usaha Tidak Boleh Kosong',
      );
      hasErrors = true;
    } else if (name.length < 3) {
      updatedFields['name'] = updatedFields['name']!.copyWith(
        error: 'Nama usaha minimal 3 karakter',
      );
      hasErrors = true;
    } else {
      updatedFields['name'] = updatedFields['name']!.clearError();
    }

    // Validate description
    final description = formFields['description']?.value as String? ?? '';
    if (description.isEmpty) {
      updatedFields['description'] = updatedFields['description']!.copyWith(
        error: 'Deskripsi Aktivitas Usaha Tidak Boleh Kosong',
      );
      hasErrors = true;
    } else if (description.length < 5) {
      updatedFields['description'] = updatedFields['description']!.copyWith(
        error: 'Deskripsi Aktivitas Usaha minimal 5 karakter',
      );
      hasErrors = true;
    } else {
      updatedFields['description'] = updatedFields['description']!.clearError();
    }

    // // Validate address
    // final address = formFields['address']?.value as String? ?? '';
    // if (address.isEmpty) {
    //   updatedFields['address'] = updatedFields['address']!.copyWith(
    //     error: 'Alamat Tidak Boleh Kosong',
    //   );
    //   hasErrors = true;
    // } else {
    //   updatedFields['address'] = updatedFields['address']!.clearError();
    // }

    // Validate building
    final building = formFields['building']?.value as BuildingStatus?;
    if (building == null) {
      updatedFields['building'] = updatedFields['building']!.copyWith(
        error: 'Status Bangunan Tidak Boleh Kosong',
      );
      hasErrors = true;
    } else {
      updatedFields['building'] = updatedFields['building']!.clearError();
    }

    // Validate sector
    final sector = formFields['sector']?.value as Sector?;
    if (sector == null) {
      updatedFields['sector'] = updatedFields['sector']!.copyWith(
        error: 'Sektor Tidak Boleh Kosong',
      );
      hasErrors = true;
    } else {
      updatedFields['sector'] = updatedFields['sector']!.clearError();
    }

    return ValidationResult(updatedFields, hasErrors);
  }

  // Future<Position> _getAccuratePosition({
  //   int maxRetry = 5,
  //   int attempt = 1,
  //   double desiredAccuracy = MapConfig.desiredAccuracy,
  // }) async {
  //   Position position = await _getCurrentPosition();

  //   if (position.accuracy <= desiredAccuracy) {
  //     return position;
  //   }

  //   if (attempt >= maxRetry) {
  //     // Return the last known position, even if not accurate enough
  //     return position;
  //   }

  //   return await _getAccuratePosition(
  //     maxRetry: maxRetry,
  //     attempt: attempt + 1,
  //     desiredAccuracy: desiredAccuracy,
  //   );
  // }

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

  bool _hasAlreadyRequestedArea({
    required LatLng position,
    required List<RequestedArea> requestedAreas,
  }) {
    final paddedBounds = MapHelper.paddedAreaFromPoint(center: position);

    return requestedAreas.any((area) => area.containsBounds(paddedBounds));
  }

  /// Calculate the centroid (geometric center) of a polygon from its points
  /// Returns the center point
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

class ValidationResult {
  final Map<String, TaggingFormFieldState<dynamic>> updatedFields;
  final bool hasErrors;

  ValidationResult(this.updatedFields, this.hasErrors);
}
