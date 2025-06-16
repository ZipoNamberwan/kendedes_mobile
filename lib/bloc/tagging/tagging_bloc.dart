import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_ce/hive.dart';
import 'package:kendedes_mobile/classes/api_server_handler.dart';
import 'package:kendedes_mobile/classes/map_config.dart';
import 'package:kendedes_mobile/classes/repositories/auth_repository.dart';
import 'package:kendedes_mobile/classes/repositories/tagging_repository.dart';
import 'package:kendedes_mobile/hive/hive_boxes.dart';
import 'package:kendedes_mobile/models/project.dart';
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
        final box = await Hive.openBox<TagData>(tagDataBox);
        final List<TagData> tags =
            box.values
                .where((tag) => tag.project.id == event.project.id)
                .toList();

        final User? currentUser = AuthRepository().getUser();

        // Emit success state with initial data
        emit(
          InitializingSuccess(
            data: state.data.copyWith(
              project: event.project,
              tagDataBox: box,
              tags: tags,
              currentUser: currentUser,
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
      emit(TagDeletedLoading(data: state.data.copyWith(isDeletingTag: true)));

      try {
        if (event.tagData.hasSentToServer == false) {
          await state.data.tagDataBox?.delete(event.tagData.id);
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
        } else {
          await ApiServerHandler.run(
            action: () async {
              await TaggingRepository().deleteTagging(event.tagData.id);
              await state.data.tagDataBox?.delete(event.tagData.id);
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
              emit(
                TokenExpired(data: state.data.copyWith(isDeletingTag: false)),
              );
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
        }
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

    on<SelectTag>((event, emit) {
      emit(
        TagSelected(data: state.data.copyWith(selectedTags: [event.tagData])),
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

    on<DeleteSelectedTags>((event, emit) {
      try {
        state.data.tagDataBox?.deleteAll(
          state.data.selectedTags.map((tag) => tag.id),
        );
      } catch (e) {
        emit(TagDeletedError(errorMessage: e.toString(), data: state.data));
        return;
      }

      emit(
        TagDeletedSuccess(
          successMessage:
              'Berhasil menghapus ${state.data.selectedTags.length} tagging terpilih',
          data: state.data.copyWith(
            tags:
                state.data.tags
                    .where((tag) => !state.data.selectedTags.contains(tag))
                    .toList(),
            filteredTags:
                state.data.filteredTags
                    .where((tag) => !state.data.selectedTags.contains(tag))
                    .toList(),
            selectedTags: [],
          ),
        ),
      );
    });

    on<UpdateCurrentLocation>((event, emit) async {
      emit(
        TaggingState(
          data: state.data.copyWith(currentLocation: event.newPosition),
        ),
      );
    });

    on<CreateForm>((event, emit) {
      emit(TaggingState(data: state.data.copyWith(resetForm: true)));
    });

    on<EditForm>((event, emit) {
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
        final User user =
            AuthRepository().getUser() ?? User(id: '', email: '', name: '');

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

        // 🔐 Save to Hive
        final tagBox = state.data.tagDataBox;
        await tagBox?.put(newTag.id, newTag);

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
            await tagBox?.put(savedTag.id, savedTag);

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
          user: event.tagData.user,
        );

        // 🔐 Save to Hive
        final tagBox = state.data.tagDataBox;
        await tagBox?.put(updatedTag.id, updatedTag);

        // Update tags list
        final updatedTags =
            state.data.tags
                .map((tag) => tag.id == event.tagData.id ? updatedTag : tag)
                .toList();

        emit(
          SaveFormSuccess(
            newTag: updatedTag,
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
            await TaggingRepository().updateTagging(updatedTag);
            final savedTag = updatedTag.copyWith(
              hasChanged: false,
              hasSentToServer: true,
            );
            await tagBox?.put(savedTag.id, savedTag);

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

    on<RecordTagLocation>((event, emit) async {
      emit(
        TaggingState(
          data: state.data.copyWith(isLoadingTag: true, resetForm: true),
        ),
      );

      try {
        Position position = await _getCurrentPosition();

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

    on<SetSideBarOpen>((event, emit) {
      final newDataState = state.data.copyWith(
        isSideBarOpen: event.isOpen,
        filteredTags: event.isOpen ? state.data.tags : state.data.filteredTags,
        resetAllFilter: event.isOpen,
        isMultiSelectMode: false,
      );
      if (event.isOpen) {
        emit(SideBarOpened(data: newDataState));
      } else {
        emit(SideBarClosed(data: newDataState));
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
      state.data.tagDataBox?.close();
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

            final updatedNearByTags = state.data.tags;
            final existingIds = updatedNearByTags.map((e) => e.id).toSet();

            for (final tag in tags) {
              if (!existingIds.contains(tag.id)) {
                updatedNearByTags.add(tag);
              }
            }

            emit(
              TaggingState(
                data: state.data.copyWith(
                  isTaggingInsideBoundsLoading: false,
                  tags: updatedNearByTags,
                ),
              ),
            );
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
  }

  List<TagData> _applyFilters({
    required List<TagData> allTags,
    required String? query,
    required Sector? sector,
    required ProjectType? projectType,
  }) {
    final normalizedQuery = query?.trim().toLowerCase();

    // No filters applied → return all
    if ((normalizedQuery == null || normalizedQuery.isEmpty) &&
        sector == null &&
        projectType == null) {
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

      final matchesSector = sector == null || tag.sector.key == sector.key;

      final matchesProjectType =
          projectType == null || tag.project.type.key == projectType.key;

      return matchesQuery && matchesSector && matchesProjectType;
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
}

class ValidationResult {
  final Map<String, TaggingFormFieldState<dynamic>> updatedFields;
  final bool hasErrors;

  ValidationResult(this.updatedFields, this.hasErrors);
}
