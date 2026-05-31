import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/models/area/regency.dart';
import 'package:kendedes_mobile/models/area/subdistrict.dart';
import 'package:kendedes_mobile/models/area/village.dart';

abstract class KbliEvent extends Equatable {
  const KbliEvent();
  @override
  List<Object?> get props => [];
}

class Initialize extends KbliEvent {
  const Initialize();

  @override
  List<Object?> get props => [];
}

class SelectRegency extends KbliEvent {
  final Regency? regency;
  const SelectRegency({required this.regency});

  @override
  List<Object?> get props => [regency];
}

class SelectSubdistrict extends KbliEvent {
  final Subdistrict? subdistrict;
  const SelectSubdistrict({required this.subdistrict});

  @override
  List<Object?> get props => [subdistrict];
}

class SelectVillage extends KbliEvent {
  final Village? village;
  const SelectVillage({required this.village});

  @override
  List<Object?> get props => [village];
}

class ClearSelectedRegency extends KbliEvent {
  const ClearSelectedRegency();

  @override
  List<Object?> get props => [];
}

class ClearSelectedSubdistrict extends KbliEvent {
  const ClearSelectedSubdistrict();

  @override
  List<Object?> get props => [];
}

class ClearSelectedVillage extends KbliEvent {
  const ClearSelectedVillage();

  @override
  List<Object?> get props => [];
}
