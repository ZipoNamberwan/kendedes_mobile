import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/models/tag_data.dart';

abstract class SupplementFormEvent extends Equatable {
  const SupplementFormEvent();
  @override
  List<Object?> get props => [];
}

class CreateForm extends SupplementFormEvent {
  const CreateForm();
}

class EditForm extends SupplementFormEvent {
  final TagData tagData;
  const EditForm({required this.tagData});
}

class SetSupplementFormField extends SupplementFormEvent {
  final String key;
  final dynamic value;
  const SetSupplementFormField(this.key, this.value);

  @override
  List<Object?> get props => [key, value];
}

class SaveForm extends SupplementFormEvent {
  const SaveForm();
}

class CancelForm extends SupplementFormEvent {
  const CancelForm();
}