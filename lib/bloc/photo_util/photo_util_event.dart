import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

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

class SetFormField extends PhotoUtilEvent {
  final String key;
  final dynamic value;
  const SetFormField(this.key, this.value);

  @override
  List<Object?> get props => [key, value];
}

class SetPhotoFileField extends PhotoUtilEvent {
  final XFile xFile;
  const SetPhotoFileField(this.xFile);

  @override
  List<Object?> get props => [xFile];
}
