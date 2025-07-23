import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/models/label_type.dart';
import 'package:kendedes_mobile/models/map_type.dart';
import 'package:kendedes_mobile/models/polygon.dart';
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

class SetTaggingSideBarOpen extends TaggingEvent {
  final bool isOpen;
  const SetTaggingSideBarOpen(this.isOpen);
}

class SetPolygonSideBarOpen extends TaggingEvent {
  final bool isOpen;
  const SetPolygonSideBarOpen(this.isOpen);
}

class ClearTagSelection extends TaggingEvent {
  const ClearTagSelection();
}

class DeleteSelectedTags extends TaggingEvent {
  const DeleteSelectedTags();
}

class RecordTagLocation extends TaggingEvent {
  final bool forceTagging;
  const RecordTagLocation({required this.forceTagging});
}

class CreateForm extends TaggingEvent {
  const CreateForm();
}

class EditForm extends TaggingEvent {
  final TagData tagData;
  const EditForm({required this.tagData});
}

class SetTaggingFormField extends TaggingEvent {
  final String key;
  final dynamic value;
  const SetTaggingFormField(this.key, this.value);

  @override
  List<Object?> get props => [key, value];
}

class SaveCreateForm extends TaggingEvent {
  const SaveCreateForm();
}

class SaveEditForm extends TaggingEvent {
  final TagData tagData;
  const SaveEditForm({required this.tagData});
}

class UploadSelectedTags extends TaggingEvent {
  final bool uploadAll;
  const UploadSelectedTags({required this.uploadAll});
}

class SearchTagging extends TaggingEvent {
  final String? query;
  final bool? reset;
  const SearchTagging({this.query, this.reset});
}

class FilterTaggingBySector extends TaggingEvent {
  final Sector? sector;
  final bool? reset;
  const FilterTaggingBySector({this.sector, this.reset});
}

class FilterTaggingByProjectType extends TaggingEvent {
  final ProjectType? projectType;
  final bool? reset;
  const FilterTaggingByProjectType({this.projectType, this.reset});
}

class FilterCurrentProject extends TaggingEvent {
  final bool isFilterCurrentProject;
  const FilterCurrentProject({required this.isFilterCurrentProject});
}

class FilterHasSentToServer extends TaggingEvent {
  final bool isFilterSentToServer;
  const FilterHasSentToServer({required this.isFilterSentToServer});
}

class ResetAllFilter extends TaggingEvent {
  const ResetAllFilter();
}

class SelectLabelType extends TaggingEvent {
  final LabelType? labelTypeKey;
  const SelectLabelType(this.labelTypeKey);
}

class SelectMapType extends TaggingEvent {
  final MapType? mapTypeKey;
  const SelectMapType(this.mapTypeKey);
}

class CloseProject extends TaggingEvent {
  const CloseProject();
}

class UpdateVisibleMapBounds extends TaggingEvent {
  final LatLng sw;
  final LatLng ne;
  const UpdateVisibleMapBounds({required this.sw, required this.ne});
}

class GetTaggingInsideBounds extends TaggingEvent {
  const GetTaggingInsideBounds();
}

//Move tag to new location Event
class StartMoveMode extends TaggingEvent {
  final TagData tagData;
  const StartMoveMode({required this.tagData});
}

class MoveTag extends TaggingEvent {
  final LatLng newPosition;
  const MoveTag({required this.newPosition});
}

class CancelMoveMode extends TaggingEvent {
  const CancelMoveMode();
}

class SaveMoveTag extends TaggingEvent {
  const SaveMoveTag();
}

class UpdatePolygon extends TaggingEvent {
  const UpdatePolygon();
}

class SelectPolygon extends TaggingEvent {
  final Polygon polygon;
  const SelectPolygon({required this.polygon});
}

class DeletePolygon extends TaggingEvent {
  final Polygon polygon;
  const DeletePolygon({required this.polygon});
}
