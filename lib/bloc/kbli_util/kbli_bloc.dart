import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/kbli_util/kbli_event.dart';
import 'package:kendedes_mobile/bloc/kbli_util/kbli_state.dart';
import 'package:kendedes_mobile/classes/api_server_handler.dart';
import 'package:kendedes_mobile/classes/repositories/browse_repository.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/area_db_repository.dart';
import 'package:kendedes_mobile/classes/repositories/util/kbli_repository.dart';
import 'package:kendedes_mobile/models/area/regency.dart';
import 'package:kendedes_mobile/models/area/subdistrict.dart';
import 'package:kendedes_mobile/models/area/village.dart';
import 'package:kendedes_mobile/models/kbli.dart';

class KbliBloc extends Bloc<KbliEvent, KbliState> {
  KbliBloc() : super(Initializing(data: KbliStateData.initial())) {
    on<Initialize>((event, emit) async {
      try {
        await KbliRepository().init();

        final bool isRegenciesEmpty =
            await AreaDbRepository().isRegenciesEmpty();
        final bool isSubdistrictsEmpty =
            await AreaDbRepository().isSubdistrictsEmpty();
        if (isRegenciesEmpty || isSubdistrictsEmpty) {
          await AreaDbRepository().insertBatchRegencies(
            Regency.getPredefinedRegencies(),
          );
          await AreaDbRepository().insertBatchSubdistricts(
            Subdistrict.getPredefinedSubdistricts(),
          );
        }

        final regencies = await AreaDbRepository().getRegencies();

        emit(
          KbliState(
            data: state.data.copyWith(
              isInitializing: false,
              regencies: regencies,
            ),
          ),
        );
      } catch (e) {
        emit(
          InitializingError(
            errorMessage: e.toString(),
            data: state.data.copyWith(isInitializing: false),
          ),
        );
      }
    });

    on<SelectRegency>((event, emit) async {
      emit(
        KbliState(
          data: state.data.copyWith(
            isLoadingSubdistrict: true,
            selectedRegency: event.regency,
            isRegencyError: false,
            isSubdistrictError: false,
            isVillageError: false,
            clearSelectedSubdistrict: true,
            clearSelectedVillage: true,
            subdistricts: [],
            kblis: [],
          ),
        ),
      );
      List<Subdistrict> subdistricts = [];
      if (event.regency?.id != null) {
        subdistricts = await AreaDbRepository().getSubdistrictsByRegency(
          event.regency!.id,
        );
      }
      emit(
        KbliState(
          data: state.data.copyWith(
            subdistricts: subdistricts,
            isLoadingSubdistrict: false,
          ),
        ),
      );
    });

    on<SelectSubdistrict>((event, emit) async {
      await ApiServerHandler.run(
        action: () async {
          emit(
            KbliState(
              data: state.data.copyWith(
                selectedSubdistrict: event.subdistrict,
                isLoadingVillage: true,
                isLoadingKblis: true,
                isSubdistrictError: false,
                isVillageError: false,
                isKblisError: false,
                clearSelectedVillage: true,
                villages: [],
                kblis: [],
              ),
            ),
          );

          List<Village> villages = [];
          List<Kbli> kblis = [];

          if (event.subdistrict?.id != null) {
            villages = await BrowseRepository().getVillagesBySubdistrictId(
              event.subdistrict!.id,
            );
            kblis = await KbliRepository().getKbliStatistics(
              type: 'subdistrict',
              longCode: event.subdistrict!.longCode,
            );
          }

          emit(
            KbliState(
              data: state.data.copyWith(
                villages: villages,
                isLoadingVillage: false,
                kblis: kblis,
                isLoadingKblis: false,
              ),
            ),
          );
        },
        onLoginExpired: (e) {
          emit(
            TokenExpired(
              data: state.data.copyWith(
                isLoadingVillage: false,
                isLoadingKblis: false,
              ),
            ),
          );
        },
        onDataProviderError: (e) {
          emit(
            KbliStatisticsError(
              errorMessage: e.toString(),
              data: state.data.copyWith(
                isLoadingVillage: false,
                isLoadingKblis: false,
                isVillageError: true,
                isKblisError: true,
              ),
            ),
          );
        },
        onOtherError: (e) {
          emit(
            KbliStatisticsError(
              errorMessage: e.toString(),
              data: state.data.copyWith(
                isLoadingVillage: false,
                isLoadingKblis: false,
                isVillageError: true,
                isKblisError: true,
              ),
            ),
          );
        },
      );
    });

    on<SelectVillage>((event, emit) async {
      await ApiServerHandler.run(
        action: () async {
          emit(
            KbliState(
              data: state.data.copyWith(
                selectedVillage: event.village,
                isLoadingKblis: true,
                isKblisError: false,
                kblis: [],
              ),
            ),
          );

          List<Kbli> kblis = [];

          if (event.village?.id != null) {
            kblis = await KbliRepository().getKbliStatistics(
              type: 'village',
              longCode: event.village!.longCode,
            );
          } else if (state.data.selectedSubdistrict != null) {
            kblis = await KbliRepository().getKbliStatistics(
              type: 'subdistrict',
              longCode: state.data.selectedSubdistrict!.longCode,
            );
          }

          emit(
            KbliState(
              data: state.data.copyWith(
                kblis: kblis,
                isLoadingKblis: false,
              ),
            ),
          );
        },
        onLoginExpired: (e) {
          emit(
            TokenExpired(
              data: state.data.copyWith(
                isLoadingKblis: false,
              ),
            ),
          );
        },
        onDataProviderError: (e) {
          emit(
            KbliStatisticsError(
              errorMessage: e.toString(),
              data: state.data.copyWith(
                isLoadingKblis: false,
                isKblisError: true,
              ),
            ),
          );
        },
        onOtherError: (e) {
          emit(
            KbliStatisticsError(
              errorMessage: e.toString(),
              data: state.data.copyWith(
                isLoadingKblis: false,
                isKblisError: true,
              ),
            ),
          );
        },
      );
    });

    on<ClearSelectedRegency>((event, emit) {
      emit(
        KbliState(
          data: state.data.copyWith(
            clearSelectedRegency: true,
            clearSelectedSubdistrict: true,
            clearSelectedVillage: true,
            kblis: [],
          ),
        ),
      );
    });

    on<ClearSelectedSubdistrict>((event, emit) async {
      emit(
        KbliState(
          data: state.data.copyWith(
            clearSelectedSubdistrict: true,
            clearSelectedVillage: true,
            kblis: [],
          ),
        ),
      );
    });

    on<ClearSelectedVillage>((event, emit) async {
      emit(
        KbliState(
          data: state.data.copyWith(
            clearSelectedVillage: true,
            isLoadingKblis: true,
            isKblisError: false,
            kblis: [],
          ),
        ),
      );

      List<Kbli> kblis = [];
      try {
        if (state.data.selectedSubdistrict != null) {
          kblis = await KbliRepository().getKbliStatistics(
            type: 'subdistrict',
            longCode: state.data.selectedSubdistrict!.longCode,
          );
        }
        emit(
          KbliState(
            data: state.data.copyWith(
              kblis: kblis,
              isLoadingKblis: false,
            ),
          ),
        );
      } catch (e) {
        emit(
          KbliStatisticsError(
            errorMessage: e.toString(),
            data: state.data.copyWith(
              isLoadingKblis: false,
              isKblisError: true,
            ),
          ),
        );
      }
    });
  }
}
