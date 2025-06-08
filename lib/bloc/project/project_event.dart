import 'package:equatable/equatable.dart';

abstract class ProjectEvent extends Equatable {
  const ProjectEvent();
  @override
  List<Object?> get props => [];
}

class Initialize extends ProjectEvent {
  const Initialize();

  @override
  List<Object?> get props => [];
}

class SaveProject extends ProjectEvent {
  const SaveProject();

  @override
  List<Object?> get props => [];
}

class DeleteProject extends ProjectEvent {
  final String id;
  const DeleteProject(this.id);

  @override
  List<Object?> get props => [id];
}

class SetProjectFormField extends ProjectEvent {
  final String key;
  final dynamic value;
  const SetProjectFormField(this.key, this.value);

  @override
  List<Object?> get props => [key, value];
}

class LoadProject extends ProjectEvent {
  final String id;
  const LoadProject(this.id);

  @override
  List<Object?> get props => [id];
}

class ResetProjectForm extends ProjectEvent {
  const ResetProjectForm();

  @override
  List<Object?> get props => [];
}
