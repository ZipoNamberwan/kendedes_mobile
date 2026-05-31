import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/models/area/regency.dart';
import 'package:kendedes_mobile/models/area/subdistrict.dart';
import 'package:kendedes_mobile/models/area/village.dart';
import 'package:kendedes_mobile/models/kbli.dart';

class KbliState extends Equatable {
  final KbliStateData data;

  const KbliState({required this.data});

  @override
  List<Object> get props => [data];
}

class Initializing extends KbliState {
  const Initializing({required super.data});
}

class InitializingError extends KbliState {
  final String errorMessage;
  const InitializingError({required this.errorMessage, required super.data});

  @override
  List<Object> get props => [errorMessage, data];
}

class TokenExpired extends KbliState {
  const TokenExpired({required super.data});

  @override
  List<Object> get props => [data];
}

class KbliStatisticsError extends KbliState {
  final String errorMessage;
  const KbliStatisticsError({required this.errorMessage, required super.data});

  @override
  List<Object> get props => [errorMessage, data];
}

class KbliStateData {
  final bool isInitializing;
  final List<Regency> regencies;
  final List<Subdistrict> subdistricts;
  final List<Village> villages;
  final Regency? selectedRegency;
  final Subdistrict? selectedSubdistrict;
  final Village? selectedVillage;
  final bool isLoadingRegency;
  final bool isLoadingSubdistrict;
  final bool isLoadingVillage;
  final bool isRegencyError;
  final bool isSubdistrictError;
  final bool isVillageError;

  final List<Kbli> kblis;
  final bool isLoadingKblis;
  final bool isKblisError;

  const KbliStateData({
    required this.isInitializing,
    required this.regencies,
    required this.subdistricts,
    required this.villages,
    required this.selectedRegency,
    required this.selectedSubdistrict,
    required this.selectedVillage,
    required this.isLoadingRegency,
    required this.isLoadingSubdistrict,
    required this.isLoadingVillage,
    required this.isRegencyError,
    required this.isSubdistrictError,
    required this.isVillageError,
    required this.kblis,
    required this.isLoadingKblis,
    required this.isKblisError,
  });

  KbliStateData copyWith({
    bool? isInitializing,
    List<Regency>? regencies,
    List<Subdistrict>? subdistricts,
    List<Village>? villages,
    Regency? selectedRegency,
    Subdistrict? selectedSubdistrict,
    Village? selectedVillage,
    bool? isLoadingRegency,
    bool? isLoadingSubdistrict,
    bool? isLoadingVillage,
    bool? isRegencyError,
    bool? isSubdistrictError,
    bool? isVillageError,
    bool? clearSelectedRegency,
    bool? clearSelectedSubdistrict,
    bool? clearSelectedVillage,
    List<Kbli>? kblis,
    bool? isLoadingKblis,
    bool? isKblisError,
  }) {
    return KbliStateData(
      isInitializing: isInitializing ?? this.isInitializing,
      regencies: regencies ?? this.regencies,
      subdistricts:
          (clearSelectedRegency ?? false)
              ? []
              : subdistricts ?? this.subdistricts,
      villages:
          (clearSelectedSubdistrict ?? false) ? [] : villages ?? this.villages,
      selectedRegency:
          (clearSelectedRegency ?? false)
              ? null
              : selectedRegency ?? this.selectedRegency,
      selectedSubdistrict:
          (clearSelectedSubdistrict ?? false)
              ? null
              : selectedSubdistrict ?? this.selectedSubdistrict,
      selectedVillage:
          (clearSelectedVillage ?? false)
              ? null
              : selectedVillage ?? this.selectedVillage,
      isLoadingRegency: isLoadingRegency ?? this.isLoadingRegency,
      isLoadingSubdistrict: isLoadingSubdistrict ?? this.isLoadingSubdistrict,
      isLoadingVillage: isLoadingVillage ?? this.isLoadingVillage,
      isRegencyError: isRegencyError ?? this.isRegencyError,
      isSubdistrictError: isSubdistrictError ?? this.isSubdistrictError,
      isVillageError: isVillageError ?? this.isVillageError,
      kblis: kblis ?? this.kblis,
      isLoadingKblis: isLoadingKblis ?? this.isLoadingKblis,
      isKblisError: isKblisError ?? this.isKblisError,
    );
  }

  factory KbliStateData.initial() => const KbliStateData(
    isInitializing: true,
    regencies: [],
    subdistricts: [],
    villages: [],
    selectedRegency: null,
    selectedSubdistrict: null,
    selectedVillage: null,
    isLoadingRegency: false,
    isLoadingSubdistrict: false,
    isLoadingVillage: false,
    isRegencyError: false,
    isSubdistrictError: false,
    isVillageError: false,
    kblis: [],
    isLoadingKblis: false,
    isKblisError: false,
  );
}
