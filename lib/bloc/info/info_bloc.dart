import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kendedes_mobile/bloc/info/info_event.dart';
import 'package:kendedes_mobile/bloc/info/info_state.dart';
import 'package:kendedes_mobile/classes/api_server_handler.dart';
import 'package:kendedes_mobile/classes/repositories/util/info_db_repository.dart';
import 'package:kendedes_mobile/classes/repositories/util/info_repository.dart';
import 'package:kendedes_mobile/models/info_util/Info.dart';

class InfoBloc extends Bloc<InfoEvent, InfoState> {
  final InfoDbRepository _infoDbRepository = InfoDbRepository();
  final InfoRepository _infoRepository = InfoRepository();

  InfoBloc() : super(InitState()) {
    on<Initialize>((event, emit) async {
      // 1. Load all infos from local DB
      final localInfos = await _infoDbRepository.getAllInfos();

      // 2. Emit local infos, mark local loading done
      emit(
        InfoState(
          data: state.data.copyWith(
            infos: localInfos,
            filteredInfos: localInfos,
            isLoadingFromLocal: false,
          ),
        ),
      );

      // 3. Trigger server sync
      add(const GetInfos());
    });

    on<GetInfos>((event, emit) async {
      emit(InfoState(data: state.data.copyWith(isLoadingFromServer: true)));

      await ApiServerHandler.run(
        action: () async {
          // 1. Get last check timestamp from local storage
          final lastCheckDate = _infoDbRepository.getLastCheckInfos();
          final String? lastCheckStr =
              lastCheckDate != null
                  ? DateFormat('yyyy-MM-dd HH:mm:ss').format(lastCheckDate)
                  : null;

          // 2. Fetch infos from server, passing last_check if available
          final serverInfos = await _infoRepository.getInfoList(
            lastCheck: lastCheckStr,
          );

          // 3. Save all server infos to local DB
          await _infoDbRepository.saveInfoList(serverInfos);

          // 4. Save last check timestamp as now
          await _infoDbRepository.saveLastCheckInfos(
            DateTime.now().millisecondsSinceEpoch,
          );

          // 5. Reload all infos from local DB and emit updated state
          final updatedInfos = await _infoDbRepository.getAllInfos();
          emit(
            InfoState(
              data: state.data.copyWith(
                infos: updatedInfos,
                filteredInfos: updatedInfos,
                // isLoadingFromServer: false,
              ),
            ),
          );
        },
        onLoginExpired: (e) {
          emit(
            TokenExpired(data: state.data.copyWith(isLoadingFromServer: false)),
          );
        },
        onDataProviderError: (e) {
          emit(
            LoadFromServerFailed(
              errorMessage: e.toString(),
              data: state.data.copyWith(isLoadingFromServer: false),
            ),
          );
        },
        onOtherError: (e) {
          emit(
            LoadFromServerFailed(
              errorMessage: e.toString(),
              data: state.data.copyWith(isLoadingFromServer: false),
            ),
          );
        },
      );
    });

    on<GetInfoDetail>((event, emit) async {
      emit(InfoState(data: state.data.copyWith(isDetailLoading: true)));

      await ApiServerHandler.run(
        action: () async {
          Info detailInfo;

          // 1. Decide whether to fetch from server or use cached content
          final needsFetch =
              event.selectedInfo.content == null ||
              event.selectedInfo.content!.isEmpty ||
              event.selectedInfo.needUpdate;

          if (needsFetch) {
            // Fetch full detail from server
            final serverInfo = await _infoRepository.getInfoDetail(
              event.selectedInfo.id,
            );
            if (serverInfo == null) {
              emit(
                GetDetailInfoFailed(
                  errorMessage: 'Data tidak ditemukan di server.',
                  data: state.data.copyWith(isDetailLoading: false),
                ),
              );
              return;
            }
            // Persist content and mark need_update = false
            await _infoDbRepository.saveContent(
              serverInfo.id,
              serverInfo.content ?? '',
            );
            await _infoDbRepository.updateNeedUpdate(
              serverInfo.id,
              needUpdate: false,
            );
            detailInfo = serverInfo;
          } else {
            // Use existing cached content
            detailInfo = event.selectedInfo;
          }

          // 2. Mark as read in local DB
          await _infoDbRepository.updateIsRead(detailInfo.id, isRead: true);

          // Build the final Info with isRead = true
          final readInfo = await _infoDbRepository.getInfoById(detailInfo.id);
          final finalInfo = readInfo ?? detailInfo;

          // 3. Update infos and filteredInfos lists with the updated item
          final updatedInfos =
              state.data.infos
                  .map((i) => i.id == finalInfo.id ? finalInfo : i)
                  .toList();
          final updatedFilteredInfos =
              state.data.filteredInfos
                  .map((i) => i.id == finalInfo.id ? finalInfo : i)
                  .toList();

          emit(
            InfoState(
              data: state.data.copyWith(
                infos: updatedInfos,
                filteredInfos: updatedFilteredInfos,
                selectedInfo: finalInfo,
                isDetailLoading: false,
              ),
            ),
          );
        },
        onLoginExpired: (e) {
          emit(TokenExpired(data: state.data.copyWith(isDetailLoading: false)));
        },
        onDataProviderError: (e) {
          emit(
            GetDetailInfoFailed(
              errorMessage: e.toString(),
              data: state.data.copyWith(isDetailLoading: false),
            ),
          );
        },
        onOtherError: (e) {
          emit(
            GetDetailInfoFailed(
              errorMessage: e.toString(),
              data: state.data.copyWith(isDetailLoading: false),
            ),
          );
        },
      );
    });

    on<SearchByKeyword>((event, emit) {
      final query = event.keyword.toLowerCase();
      final filtered =
          state.data.infos.where((info) {
            return info.title.toLowerCase().contains(query) ||
                (info.subtitle?.toLowerCase().contains(query) ?? false) ||
                (info.content?.toLowerCase().contains(query) ?? false);
          }).toList();

      // Sort by createdAt descending (newest first)
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(
        InfoState(
          data: state.data.copyWith(
            filteredInfos: filtered,
            searchQuery: event.keyword,
          ),
        ),
      );
    });
  }
}
