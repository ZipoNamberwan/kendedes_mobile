import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/bloc/browse/browse_state.dart';
import 'package:kendedes_mobile/models/area/regency.dart';
import 'package:kendedes_mobile/models/area/sls.dart';
import 'package:kendedes_mobile/models/area/subdistrict.dart';
import 'package:kendedes_mobile/models/area/village.dart';
import 'package:kendedes_mobile/models/label_type.dart';
import 'package:kendedes_mobile/models/map_type.dart';
import 'package:kendedes_mobile/models/polygon.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/models/sls_with_business.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:latlong2/latlong.dart';

abstract class BrowseEvent extends Equatable {
  const BrowseEvent();
  @override
  List<Object?> get props => [];
}

class Initialize extends BrowseEvent {
  const Initialize();
}

class GetCurrentLocation extends BrowseEvent {
  const GetCurrentLocation();
}

class UpdateZoom extends BrowseEvent {
  final double zoomLevel;
  const UpdateZoom({required this.zoomLevel});
}

class UpdateRotation extends BrowseEvent {
  final double rotation;
  const UpdateRotation({required this.rotation});
}

class UpdateCurrentLocation extends BrowseEvent {
  final LatLng newPosition;
  const UpdateCurrentLocation({required this.newPosition});
}

class UpdateVisibleMapBounds extends BrowseEvent {
  final LatLng sw;
  final LatLng ne;
  const UpdateVisibleMapBounds({required this.sw, required this.ne});
}

class GetBusinessInsideBounds extends BrowseEvent {
  const GetBusinessInsideBounds();
}

class GetBusinessByArea extends BrowseEvent {
  final Sls sls;
  const GetBusinessByArea({required this.sls});
}

class GetBusinessByPoint extends BrowseEvent {
  final LatLng point;
  const GetBusinessByPoint({required this.point});
}

class SetBusinessLoadMode extends BrowseEvent {
  final BusinessLoadMode loadMode;
  const SetBusinessLoadMode({required this.loadMode});
}

class ToggleLoadBusinessContainer extends BrowseEvent {
  const ToggleLoadBusinessContainer();
}

class SelectRegency extends BrowseEvent {
  final Regency? regency;
  const SelectRegency({required this.regency});

  @override
  List<Object?> get props => [regency];
}

class SelectSubdistrict extends BrowseEvent {
  final Subdistrict? subdistrict;
  const SelectSubdistrict({required this.subdistrict});

  @override
  List<Object?> get props => [subdistrict];
}

class SelectVillage extends BrowseEvent {
  final Village? village;
  const SelectVillage({required this.village});

  @override
  List<Object?> get props => [village];
}

class SelectSls extends BrowseEvent {
  final Sls? sls;
  const SelectSls({required this.sls});

  @override
  List<Object?> get props => [sls];
}

class ClearSelectedRegency extends BrowseEvent {
  const ClearSelectedRegency();

  @override
  List<Object?> get props => [];
}

class ClearSelectedSubdistrict extends BrowseEvent {
  const ClearSelectedSubdistrict();

  @override
  List<Object?> get props => [];
}

class ClearSelectedVillage extends BrowseEvent {
  const ClearSelectedVillage();

  @override
  List<Object?> get props => [];
}

class ClearSelectedSls extends BrowseEvent {
  const ClearSelectedSls();

  @override
  List<Object?> get props => [];
}

class SelectLabelType extends BrowseEvent {
  final LabelType? labelTypeKey;
  const SelectLabelType(this.labelTypeKey);
}

class SelectMapType extends BrowseEvent {
  final MapType? mapTypeKey;
  const SelectMapType(this.mapTypeKey);
}

class SetPolygonSideBarOpen extends BrowseEvent {
  final bool isOpen;
  const SetPolygonSideBarOpen(this.isOpen);
}

class UpdatePolygon extends BrowseEvent {
  const UpdatePolygon();
}

class SelectPolygon extends BrowseEvent {
  final Polygon polygon;
  const SelectPolygon({required this.polygon});
}

class DeletePolygon extends BrowseEvent {
  final Polygon polygon;
  const DeletePolygon({required this.polygon});
}

class SetSlsWithBusinessSidebarOpen extends BrowseEvent {
  final bool isOpen;
  const SetSlsWithBusinessSidebarOpen(this.isOpen);
}

class DeleteSlsWithBusiness extends BrowseEvent {
  final SlsWithBusiness slsWithBusiness;
  const DeleteSlsWithBusiness({required this.slsWithBusiness});
}

class SetBrowseSideBarOpen extends BrowseEvent {
  final bool isOpen;
  const SetBrowseSideBarOpen(this.isOpen);
}

class ResetAllFilter extends BrowseEvent {
  const ResetAllFilter();
}

class SearchBusiness extends BrowseEvent {
  final String? query;
  final bool? reset;
  const SearchBusiness({this.query, this.reset});
}

class FilterBusinessByProjectType extends BrowseEvent {
  final ProjectType? projectType;
  final bool? reset;
  const FilterBusinessByProjectType({this.projectType, this.reset});
}

class FilterBusinessBySls extends BrowseEvent {
  final Sls? sls;
  final bool? reset;
  const FilterBusinessBySls({this.sls, this.reset});
}

class SelectBusiness extends BrowseEvent {
  final TagData business;
  const SelectBusiness(this.business);

  @override
  List<Object?> get props => [business];
}

class ClearBrowseSelection extends BrowseEvent {
  const ClearBrowseSelection();
}

class SearchSlsWithBusiness extends BrowseEvent {
  final String? query;
  final bool? reset;
  const SearchSlsWithBusiness({this.query, this.reset});
}

class FindSls extends BrowseEvent {
  final LatLng latLng;
  const FindSls({required this.latLng});
}

class CloseSlsFinder extends BrowseEvent {
  const CloseSlsFinder();
}
