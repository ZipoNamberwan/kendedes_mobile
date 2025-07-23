import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/models/area/regency.dart';
import 'package:kendedes_mobile/models/area/sls.dart';
import 'package:kendedes_mobile/models/area/subdistrict.dart';
import 'package:kendedes_mobile/models/area/village.dart';
import 'package:kendedes_mobile/models/polygon.dart';

abstract class PolygonEvent extends Equatable {
  const PolygonEvent();
  @override
  List<Object?> get props => [];
}

class Initialize extends PolygonEvent {
  const Initialize();

  @override
  List<Object?> get props => [];
}

class SelectRegency extends PolygonEvent {
  final Regency? regency;
  const SelectRegency({required this.regency});

  @override
  List<Object?> get props => [regency];
}

class SelectSubdistrict extends PolygonEvent {
  final Subdistrict? subdistrict;
  const SelectSubdistrict({required this.subdistrict});

  @override
  List<Object?> get props => [subdistrict];
}

class SelectVillage extends PolygonEvent {
  final Village? village;
  const SelectVillage({required this.village});

  @override
  List<Object?> get props => [village];
}

class SelectSls extends PolygonEvent {
  final Sls? sls;
  const SelectSls({required this.sls});

  @override
  List<Object?> get props => [sls];
}

class SelectPolygon extends PolygonEvent {
  final Polygon? polygon;
  const SelectPolygon({required this.polygon});

  @override
  List<Object?> get props => [polygon];
}

class SearchPolygon extends PolygonEvent {
  final String? query;
  final bool? reset;
  const SearchPolygon({this.query, this.reset});

  @override
  List<Object?> get props => [query, reset];
}

class DownloadInstallPolygon extends PolygonEvent {
  final String projectId;
  const DownloadInstallPolygon({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}
