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
  const SetFormField({required this.key, required this.value});
  @override
  List<Object?> get props => [key, value];
}

class SetPhotoFileField extends PhotoUtilEvent {
  final String key;
  final XFile xFile;
  const SetPhotoFileField({required this.key, required this.xFile});
  @override
  List<Object?> get props => [key, xFile];
}

class SaveForm extends PhotoUtilEvent {
  const SaveForm();
  @override
  List<Object?> get props => [];
}
