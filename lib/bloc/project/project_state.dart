import 'package:equatable/equatable.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/models/user.dart';

class ProjectState extends Equatable {
  final ProjectStateData data;

  const ProjectState({required this.data});

  @override
  List<Object> get props => [data];
}

class InitializingStarted extends ProjectState {
  const InitializingStarted({required super.data});
}

class InitializingSuccess extends ProjectState {
  const InitializingSuccess({required super.data});
}

class InitializingError extends ProjectState {
  final String errorMessage;
  const InitializingError({required this.errorMessage, required super.data});
}

class ProjectLoaded extends ProjectState {
  const ProjectLoaded({required super.data});
}

class ProjectAddedSuccess extends ProjectState {
  const ProjectAddedSuccess({required super.data});
}

class ProjectAddedError extends ProjectState {
  final String errorMessage;
  const ProjectAddedError({required this.errorMessage, required super.data});
}

class ProjectUpdatedSuccess extends ProjectState {
  const ProjectUpdatedSuccess({required super.data});
}

class ProjectUpdatedError extends ProjectState {
  final String errorMessage;
  const ProjectUpdatedError({required this.errorMessage, required super.data});
}

class ProjectDeletedSuccess extends ProjectState {
  const ProjectDeletedSuccess({required super.data});
}

class ProjectDeletedError extends ProjectState {
  final String errorMessage;
  const ProjectDeletedError({required this.errorMessage, required super.data});
}

class TokenExpired extends ProjectState {
  const TokenExpired({required super.data});
}

class ProjectLoadError extends ProjectState {
  final String errorMessage;
  const ProjectLoadError({required this.errorMessage, required super.data});
}

class SyncSuccess extends ProjectState {
  const SyncSuccess({required super.data});
}

class SyncFailed extends ProjectState {
  final String errorMessage;
  const SyncFailed({required this.errorMessage, required super.data});
}

class SearchCleared extends ProjectState {
  const SearchCleared({required super.data});
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
  final List<Project> filteredProjects;
  final Map<String, ProjectFormFieldState<dynamic>> formFields;
  final User? currentUser;

  final bool saveLoading;
  final bool initLoading;
  final bool deleteLoading;
  final bool isSyncing;
  final Map<String, Map<String, int>> tagCounts;
  final String searchKeyword;

  ProjectStateData({
    required this.projects,
    required this.filteredProjects,
    this.currentUser,
    required this.saveLoading,
    required this.initLoading,
    required this.deleteLoading,
    required this.isSyncing,
    required this.tagCounts,
    required this.searchKeyword,
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
    List<Project>? filteredProjects,
    User? currentUser,
    Map<String, ProjectFormFieldState<dynamic>>? formFields,
    bool? resetForm,
    bool? saveLoading,
    bool? initLoading,
    bool? deleteLoading,
    bool? isSyncing,
    String? searchKeyword,
    bool? clearSearch,
    Map<String, Map<String, int>>? tagCounts,
  }) {
    return ProjectStateData(
      projects: projects ?? this.projects,
      filteredProjects: filteredProjects ?? this.filteredProjects,
      currentUser: currentUser ?? this.currentUser,
      formFields:
          (resetForm ?? false)
              ? _generateFormFields()
              : formFields ?? this.formFields,
      saveLoading: saveLoading ?? this.saveLoading,
      initLoading: initLoading ?? this.initLoading,
      deleteLoading: deleteLoading ?? this.deleteLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      tagCounts: tagCounts ?? this.tagCounts,
      searchKeyword:
          clearSearch == true ? '' : (searchKeyword ?? this.searchKeyword),
    );
  }
}
