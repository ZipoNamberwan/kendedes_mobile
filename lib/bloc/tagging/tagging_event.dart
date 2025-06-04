import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:latlong2/latlong.dart';

abstract class TaggingEvent extends Equatable {
  const TaggingEvent();
  @override
  List<Object?> get props => [];
}

class InitTag extends TaggingEvent {
  final Project project;
  const InitTag({required this.project});
}

class TagLocation extends TaggingEvent {
  const TagLocation();
}

class GetCurrentLocation extends TaggingEvent {
  const GetCurrentLocation();
}

class UpdateZoom extends TaggingEvent {
  final double zoomLevel;
  const UpdateZoom({required this.zoomLevel});
}

class UpdateRotation extends TaggingEvent {
  final double rotation;
  const UpdateRotation({required this.rotation});
}

class UpdateCurrentLocation extends TaggingEvent {
  final LatLng newPosition;
  const UpdateCurrentLocation({required this.newPosition});
}

class DeleteTag extends TaggingEvent {
  final TagData tagData;
  const DeleteTag(this.tagData);

  @override
  List<Object?> get props => [tagData];
}

class SelectTag extends TaggingEvent {
  final TagData tagData;
  const SelectTag(this.tagData);

  @override
  List<Object?> get props => [tagData];
}

class AddTagToSelection extends TaggingEvent {
  final TagData tagData;
  const AddTagToSelection(this.tagData);

  @override
  List<Object?> get props => [tagData];
}

class RemoveTagFromSelection extends TaggingEvent {
  final TagData tagData;
  const RemoveTagFromSelection(this.tagData);

  @override
  List<Object?> get props => [tagData];
}

class ToggleMultiSelectMode extends TaggingEvent {
  const ToggleMultiSelectMode();
}

class ClearTagSelection extends TaggingEvent {
  const ClearTagSelection();
}

class DeleteSelectedTags extends TaggingEvent {
  const DeleteSelectedTags();
}
