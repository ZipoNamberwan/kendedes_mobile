import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import 'tagging_event.dart';
import 'tagging_state.dart';
import '../../models/tag_data.dart';

class TaggingBloc extends Bloc<TaggingEvent, TaggingState> {
  final Uuid _uuid = const Uuid();

  TaggingBloc()
    : super(
        TaggingState(
          data: TaggingStateData(
            tags: [],
            polygons: [],
            isLoadingTag: false,
            isLoadingPolygon: false,
            isLoadingCurrentLocation: false,
            currentZoom: 16.0,
          ),
        ),
      ) {
    on<TagLocation>((event, emit) {
      // TODO: Implement tag location logic
    });

    on<UpdateZoom>((event, emit) {
      emit(
        TaggingState(data: state.data.copyWith(currentZoom: event.zoomLevel)),
      );
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
      // TODO: Implement delete tag logic
    });

    on<AddTag>((event, emit) async {
      emit(TaggingState(data: state.data.copyWith(isLoadingTag: true)));

      try {
        Position position = await _getCurrentPosition();

        // Create new tag data
        final newTag = TagData(
          id: _uuid.v4(),
          type: 'Tagged Location',
          position: LatLng(position.latitude, position.longitude),
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
