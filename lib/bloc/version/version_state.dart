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
    : super(data: VersionStateData(shouldUpdate: null, version: null));
}

class UpdateNotification extends VersionState {
  const UpdateNotification({required super.data});
}

class VersionStateData {
  final bool? shouldUpdate;
  final Version? version;

  VersionStateData({this.version, this.shouldUpdate});

  VersionStateData copyWith({Version? version, bool? shouldUpdate}) {
    return VersionStateData(
      version: version ?? this.version,
      shouldUpdate: shouldUpdate ?? this.shouldUpdate,
    );
  }
}
