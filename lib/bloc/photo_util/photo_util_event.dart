import 'package:equatable/equatable.dart';

abstract class PhotoUtilEvent extends Equatable {
  const PhotoUtilEvent();
  @override
  List<Object?> get props => [];
}

class Initialize extends PhotoUtilEvent {
  const Initialize();

  @override
  List<Object?> get props => [];
}
