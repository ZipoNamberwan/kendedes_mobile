import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/models/project.dart';

class ProjectState extends Equatable {
  final ProjectStateData data;

  const ProjectState({required this.data});

  @override
  List<Object> get props => [data];
}

class ProjectLoaded extends ProjectState {
  const ProjectLoaded({required super.data});
}

class ProjectAdded extends ProjectState {
  const ProjectAdded({required super.data});
}

class ProjectUpdated extends ProjectState {
  const ProjectUpdated({required super.data});
}

class ProjectDeleted extends ProjectState {
  const ProjectDeleted({required super.data});
}

class ProjectFormFieldState<T> {
  final T? value;
  final String? error;

  ProjectFormFieldState({this.value, this.error});

  ProjectFormFieldState<T> copyWith({T? value, String? error}) {
    return ProjectFormFieldState<T>(value: value ?? this.value, error: error);
  }

  ProjectFormFieldState<T> clearError() => copyWith(error: null);
}

class ProjectStateData {
  final List<Project> projects;
  final Map<String, ProjectFormFieldState<dynamic>> formFields;

  ProjectStateData({
    required this.projects,
    Map<String, ProjectFormFieldState<dynamic>>? formFields,
  }) : formFields = formFields ?? _generateFormFields();

  // Automatically generate form fields based on defined field keys
  static Map<String, ProjectFormFieldState<dynamic>> _generateFormFields() {
    final formFields = <String, ProjectFormFieldState<dynamic>>{};

    formFields['name'] = ProjectFormFieldState<String>();
    formFields['id'] = ProjectFormFieldState<String>();
    formFields['description'] = ProjectFormFieldState<String?>();

    return formFields;
  }

  ProjectStateData copyWith({
    List<Project>? projects,
    Map<String, ProjectFormFieldState<dynamic>>? formFields,
    bool? resetForm,
  }) {
    return ProjectStateData(
      projects: projects ?? this.projects,
      formFields:
          (resetForm ?? false)
              ? _generateFormFields()
              : formFields ?? this.formFields,
    );
  }
}
