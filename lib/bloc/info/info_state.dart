import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/models/info_util/Info.dart';

class InfoState extends Equatable {
  final InfoStateData data;

  const InfoState({required this.data});

  @override
  List<Object> get props => [data];
}

class InitState extends InfoState {
  InitState()
    : super(
        data: InfoStateData(
          infos: [],
          filteredInfos: [],
          isLoadingFromServer: false,
          isLoadingFromLocal: true,
          isDetailLoading: false,
        ),
      );

  @override
  List<Object> get props => [data];
}

class InitFailed extends InfoState {
  final String errorMessage;
  const InitFailed({required super.data, required this.errorMessage});

  @override
  List<Object> get props => [data, errorMessage];
}

class LoadFromServerFailed extends InfoState {
  final String errorMessage;
  const LoadFromServerFailed({required super.data, required this.errorMessage});

  @override
  List<Object> get props => [data, errorMessage];
}

class TokenExpired extends InfoState {
  const TokenExpired({required super.data});

  @override
  List<Object> get props => [data];
}

class GetDetailInfoFailed extends InfoState {
  final String errorMessage;
  const GetDetailInfoFailed({required super.data, required this.errorMessage});

  @override
  List<Object> get props => [data, errorMessage];
}

class InfoStateData {
  final List<Info> infos;
  final List<Info> filteredInfos;
  final bool isLoadingFromServer;
  final bool isLoadingFromLocal;
  final bool isDetailLoading;
  final Info? selectedInfo;
  final String? searchQuery;

  const InfoStateData({
    required this.infos,
    required this.filteredInfos,
    required this.isLoadingFromServer,
    required this.isLoadingFromLocal,
    required this.isDetailLoading,
    this.selectedInfo,
    this.searchQuery
  });

  InfoStateData copyWith({
    List<Info>? infos,
    List<Info>? filteredInfos,
    bool? isLoadingFromServer,
    bool? isLoadingFromLocal,
    bool? isDetailLoading,
    Info? selectedInfo,
    String? searchQuery,
  }) {
    return InfoStateData(
      infos: infos ?? this.infos,
      filteredInfos: filteredInfos ?? this.filteredInfos,
      isLoadingFromServer: isLoadingFromServer ?? this.isLoadingFromServer,
      isLoadingFromLocal: isLoadingFromLocal ?? this.isLoadingFromLocal,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      selectedInfo: selectedInfo ?? this.selectedInfo,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
