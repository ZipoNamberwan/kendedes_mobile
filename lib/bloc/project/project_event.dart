import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/models/project.dart';

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

class StoreProject extends ProjectEvent {
  const StoreProject();

  @override
  List<Object?> get props => [];
}

class UpdateProject extends ProjectEvent {
  final Project project;
  const UpdateProject({required this.project});

  @override
  List<Object?> get props => [project];
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

class SyncProjects extends ProjectEvent {
  const SyncProjects();

  @override
  List<Object?> get props => [];
}

class RecalculateTags extends ProjectEvent {
  const RecalculateTags();

  @override
  List<Object?> get props => [];
}
