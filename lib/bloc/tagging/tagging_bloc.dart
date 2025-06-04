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
          ),
        ),
      ) {
    on<InitTag>((event, emit) {
      emit(TaggingState(data: state.data.copyWith(project: event.project)));
    });

    on<TagLocation>((event, emit) async {
      emit(TaggingState(data: state.data.copyWith(isLoadingTag: true)));

      try {
        Position position = await _getCurrentPosition();

        final time = DateTime.now();
        // Create new tag data
        final newTag = TagData(
          id: _uuid.v4(),
          position: LatLng(position.latitude, position.longitude),
          createdAt: time,
          updatedAt: time,
          hasChanged: true,
          type: TagType.auto,
          initialPosition: LatLng(position.latitude, position.longitude),
          isDeleted: false,
        );

        // Add to existing tags
        final updatedTags = List<TagData>.from(state.data.tags)..add(newTag);

        emit(
          TagSuccess(
            newTag: newTag,
            data: state.data.copyWith(tags: updatedTags, isLoadingTag: false),
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
