import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/models/area/regency.dart';
import 'package:kendedes_mobile/models/area/sls.dart';
import 'package:kendedes_mobile/models/area/subdistrict.dart';
import 'package:kendedes_mobile/models/area/village.dart';
import 'package:kendedes_mobile/models/label_type.dart';
import 'package:kendedes_mobile/models/map_type.dart';
import 'package:kendedes_mobile/models/polygon.dart';
import 'package:kendedes_mobile/models/sls_with_business.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:latlong2/latlong.dart';

abstract class MoveEvent extends Equatable {
  const MoveEvent();
  @override
  List<Object?> get props => [];
}

class Initialize extends MoveEvent {
  const Initialize();
}

class GetCurrentLocation extends MoveEvent {
  const GetCurrentLocation();
}

class UpdateZoom extends MoveEvent {
  final double zoomLevel;
  const UpdateZoom({required this.zoomLevel});
}

class UpdateRotation extends MoveEvent {
  final double rotation;
  const UpdateRotation({required this.rotation});
}

class UpdateCurrentLocation extends MoveEvent {
  final LatLng newPosition;
  const UpdateCurrentLocation({required this.newPosition});
}

class GetBusinessByArea extends MoveEvent {
  final Sls sls;
  const GetBusinessByArea({required this.sls});
}

class ToggleLoadBusinessContainer extends MoveEvent {
  const ToggleLoadBusinessContainer();
}

class SelectRegency extends MoveEvent {
  final Regency? regency;
  const SelectRegency({required this.regency});

  @override
  List<Object?> get props => [regency];
}

class SelectSubdistrict extends MoveEvent {
  final Subdistrict? subdistrict;
  const SelectSubdistrict({required this.subdistrict});

  @override
  List<Object?> get props => [subdistrict];
}

class SelectVillage extends MoveEvent {
  final Village? village;
  const SelectVillage({required this.village});

  @override
  List<Object?> get props => [village];
}

class SelectSls extends MoveEvent {
  final Sls? sls;
  const SelectSls({required this.sls});

  @override
  List<Object?> get props => [sls];
}

class ClearSelectedRegency extends MoveEvent {
  const ClearSelectedRegency();

  @override
  List<Object?> get props => [];
}

class ClearSelectedSubdistrict extends MoveEvent {
  const ClearSelectedSubdistrict();

  @override
  List<Object?> get props => [];
}

class ClearSelectedVillage extends MoveEvent {
  const ClearSelectedVillage();

  @override
  List<Object?> get props => [];
}

class ClearSelectedSls extends MoveEvent {
  const ClearSelectedSls();

  @override
  List<Object?> get props => [];
}

class SelectLabelType extends MoveEvent {
  final LabelType? labelTypeKey;
  const SelectLabelType(this.labelTypeKey);
}

class SelectMapType extends MoveEvent {
  final MapType? mapTypeKey;
  const SelectMapType(this.mapTypeKey);
}

class SetPolygonSideBarOpen extends MoveEvent {
  final bool isOpen;
  const SetPolygonSideBarOpen(this.isOpen);
}

class UpdatePolygon extends MoveEvent {
  const UpdatePolygon();
}

class SelectPolygon extends MoveEvent {
  final Polygon polygon;
  const SelectPolygon({required this.polygon});
}

class DeletePolygon extends MoveEvent {
  final Polygon polygon;
  const DeletePolygon({required this.polygon});
}

class SetSlsWithBusinessSidebarOpen extends MoveEvent {
  final bool isOpen;
  const SetSlsWithBusinessSidebarOpen(this.isOpen);
}

class DeleteSlsWithBusiness extends MoveEvent {
  final SlsWithBusiness slsWithBusiness;
  const DeleteSlsWithBusiness({required this.slsWithBusiness});
}

class SetMoveSideBarOpen extends MoveEvent {
  final bool isOpen;
  const SetMoveSideBarOpen(this.isOpen);
}

class ResetAllFilter extends MoveEvent {
  const ResetAllFilter();
}

class SearchBusiness extends MoveEvent {
  final String? query;
  final bool? reset;
  const SearchBusiness({this.query, this.reset});
}

class FilterBusinessBySls extends MoveEvent {
  final Sls? sls;
  final bool? reset;
  const FilterBusinessBySls({this.sls, this.reset});
}

class SelectBusiness extends MoveEvent {
  final TagData business;
  const SelectBusiness(this.business);

  @override
  List<Object?> get props => [business];
}

class ClearMoveSelection extends MoveEvent {
  const ClearMoveSelection();
}

class SearchSlsWithBusiness extends MoveEvent {
  final String? query;
  final bool? reset;
  const SearchSlsWithBusiness({this.query, this.reset});
}

class RefreshSlsWithBusiness extends MoveEvent {
  final SlsWithBusiness slsWithBusiness;
  const RefreshSlsWithBusiness({required this.slsWithBusiness});
}

class FindSls extends MoveEvent {
  final LatLng latLng;
  const FindSls({required this.latLng});
}

class CloseSlsFinder extends MoveEvent {
  const CloseSlsFinder();
}

class CheckBusinessDataUpdate extends MoveEvent {
  const CheckBusinessDataUpdate();
}

class UpdateSlsBusiness extends MoveEvent {
  final SlsWithBusiness slsWithBusiness;
  const UpdateSlsBusiness({required this.slsWithBusiness});
}

// Move tag to new location Event
class StartMoveMode extends MoveEvent {
  final TagData tagData;
  const StartMoveMode({required this.tagData});

  @override
  List<Object?> get props => [tagData];
}

class MoveTag extends MoveEvent {
  final LatLng newPosition;
  const MoveTag({required this.newPosition});

  @override
  List<Object?> get props => [newPosition];
}

class CancelMoveMode extends MoveEvent {
  const CancelMoveMode();
}

class SaveMoveTag extends MoveEvent {
  const SaveMoveTag();
}
