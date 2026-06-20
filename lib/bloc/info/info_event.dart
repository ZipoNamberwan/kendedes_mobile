import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/models/info_util/Info.dart';

abstract class InfoEvent extends Equatable {
  const InfoEvent();
  @override
  List<Object?> get props => [];
}

class Initialize extends InfoEvent {
  const Initialize();

  @override
  List<Object?> get props => [];
}

class GetInfos extends InfoEvent {
  const GetInfos();

  @override
  List<Object?> get props => [];
}

class SearchByKeyword extends InfoEvent {
  final String keyword;
  const SearchByKeyword({required this.keyword});

  @override
  List<Object?> get props => [keyword];
}

class GetInfoDetail extends InfoEvent {
  final Info selectedInfo;
  const GetInfoDetail({required this.selectedInfo});

  @override
  List<Object?> get props => [selectedInfo];
}
