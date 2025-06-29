import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/models/version.dart';

class VersionState extends Equatable {
  final VersionStateData data;

  const VersionState({required this.data});

  @override
  List<Object> get props => [data];
}

class CheckVersionInitializing extends VersionState {
  CheckVersionInitializing()
    : super(data: VersionStateData(shouldUpdate: null, newVersion: null));
}

class UpdateNotification extends VersionState {
  const UpdateNotification({required super.data});
}

class VersionStateData {
  final bool? shouldUpdate;
  final Version? newVersion;
  final String? currentVersionName;

  VersionStateData({this.newVersion, this.shouldUpdate, this.currentVersionName});

  VersionStateData copyWith({
    Version? newVersion,
    bool? shouldUpdate,
    String? currentVersionName,
  }) {
    return VersionStateData(
      newVersion: newVersion ?? this.newVersion,
      shouldUpdate: shouldUpdate ?? this.shouldUpdate,
      currentVersionName: currentVersionName ?? this.currentVersionName,
    );
  }
}
