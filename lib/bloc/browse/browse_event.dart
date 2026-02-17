import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/bloc/browse/browse_state.dart';
import 'package:kendedes_mobile/models/area/regency.dart';
import 'package:kendedes_mobile/models/area/sls.dart';
import 'package:kendedes_mobile/models/area/subdistrict.dart';
import 'package:kendedes_mobile/models/area/village.dart';
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

class SetBrowseViewMode extends BrowseEvent {
  final BrowseViewMode viewMode;
  const SetBrowseViewMode({required this.viewMode});
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
