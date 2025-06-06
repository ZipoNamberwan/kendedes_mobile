import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import 'tagging_event.dart';
import 'tagging_state.dart';

class TaggingBloc extends Bloc<TaggingEvent, TaggingState> {
  final Uuid _uuid = const Uuid();

  TaggingBloc()
    : super(
        TaggingState(
          data: TaggingStateData(
            project: Project(
              id: '',
              name: '',
              description: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            tags: [],
            polygons: [],
            isLoadingTag: false,
            isLoadingPolygon: false,
            isLoadingCurrentLocation: false,
            currentZoom: 16.0,
            rotation: 0.0,
            selectedTags: [],
            isMultiSelectMode: false,
            isSubmitting: false,
          ),
        ),
      ) {
    on<InitTag>((event, emit) {
      emit(TaggingState(data: state.data.copyWith(project: event.project)));
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

    on<DeleteTag>((event, emit) {
      final updatedTags = List<TagData>.from(state.data.tags)
        ..removeWhere((tag) => tag.id == event.tagData.id);

      // Also remove from selectedTags if present
      final updatedSelectedTags = List<TagData>.from(state.data.selectedTags)
        ..removeWhere((tag) => tag.id == event.tagData.id);

      emit(
        TagDeleted(
          data: state.data.copyWith(
            tags: updatedTags,
            selectedTags: updatedSelectedTags,
          ),
        ),
      );
    });

    on<SelectTag>((event, emit) {
      emit(
        TagSelected(data: state.data.copyWith(selectedTags: [event.tagData])),
      );
    });

    on<AddTagToSelection>((event, emit) {
      emit(
        TaggingState(
          data: state.data.copyWith(
            selectedTags: [...state.data.selectedTags, event.tagData],
          ),
        ),
      );
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
      emit(
        TaggingState(
          data: state.data.copyWith(
            tags:
                state.data.tags
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

    Map<String, TaggingFormFieldState<dynamic>> updateFieldValue(
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
      } else if (field is TaggingFormFieldState<LatLng>) {
        return {...fields, key: field.copyWith(value: value as LatLng)};
      }

      return fields;
    }

    on<SetTaggingFormField>((event, emit) {
      final updatedFormFields = updateFieldValue(
        state.data.formFields,
        event.key,
        event.value,
      );
      emit(
        TaggingState(data: state.data.copyWith(formFields: updatedFormFields)),
      );
    });

    on<SaveForm>((event, emit) {
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

      final newTag = _createTagData(formFields);
      // Add to existing tags
      final updatedTags = List<TagData>.from(state.data.tags)..add(newTag);

      emit(
        TagSuccess(
          newTag: newTag,
          data: state.data.copyWith(
            tags: updatedTags,
            isSubmitting: false,
            formFields: validationResult.updatedFields,
          ),
        ),
      );
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
          'position': state.data.formFields['position']!.copyWith(
            value: LatLng(position.latitude, position.longitude),
          ),
        };

        emit(
          RecordedLocation(
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

  TagData _createTagData(
    Map<String, TaggingFormFieldState<dynamic>> formFields,
  ) {
    final tagDataId = formFields['id']?.value as String?;
    final name = formFields['name']?.value as String;
    final owner = formFields['owner']?.value as String?;
    final address = formFields['address']?.value as String?;
    final building = formFields['building']?.value as BuildingStatus;
    final description = formFields['description']?.value as String;
    final sector = formFields['sector']?.value as Sector;
    final note = formFields['note']?.value as String?;
    final position = formFields['position']?.value as LatLng;

    final isNewTag = tagDataId == null || tagDataId.isEmpty;

    return TagData(
      id: isNewTag ? _uuid.v4() : tagDataId,
      position: position,
      hasChanged: true,
      type: isNewTag ? TagType.auto : TagType.move,
      isDeleted: false,
      businessName: name,
      businessOwner: owner,
      businessAddress: address,
      buildingStatus: building,
      description: description,
      sector: sector,
      note: note,
    );
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
