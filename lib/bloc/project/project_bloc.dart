import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/project/project_event.dart';
import 'package:kendedes_mobile/bloc/project/project_state.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:uuid/uuid.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final Uuid _uuid = const Uuid();

  ProjectBloc() : super(ProjectState(data: ProjectStateData(projects: []))) {
    on<SaveProject>((event, emit) {
      final formFields = state.data.formFields;
      final validationResult = _validateProjectForm(formFields);

      if (validationResult.hasErrors) {
        emit(
          ProjectState(
            data: state.data.copyWith(
              formFields: validationResult.updatedFields,
            ),
          ),
        );
        return;
      }

      final projectId = formFields['id']?.value as String?;
      final projectName = formFields['name']?.value as String;
      final projectDescription = formFields['description']?.value as String?;

      final now = DateTime.now();
      final isNewProject = projectId == null || projectId.isEmpty;

      if (isNewProject) {
        final newProject = Project(
          id: _uuid.v4(),
          name: projectName.trim(),
          description: projectDescription?.trim(),
          createdAt: now,
          updatedAt: now,
          type: ProjectType.supplementMobile,
        );

        emit(
          ProjectAdded(
            data: state.data.copyWith(
              projects: [...state.data.projects, newProject],
              resetForm: true,
            ),
          ),
        );
      } else {
        final updatedProjects =
            state.data.projects.map((project) {
              return project.id == projectId
                  ? project.copyWith(
                    name: projectName.trim(),
                    description: projectDescription?.trim(),
                    updatedAt: now,
                  )
                  : project;
            }).toList();

        emit(
          ProjectUpdated(
            data: state.data.copyWith(
              projects: updatedProjects,
              resetForm: true,
            ),
          ),
        );
      }
    });

    on<DeleteProject>((event, emit) {
      emit(
        ProjectDeleted(
          data: state.data.copyWith(
            projects:
                state.data.projects
                    .where((project) => project.id != event.id)
                    .toList(),
          ),
        ),
      );
    });

    Map<String, ProjectFormFieldState<dynamic>> updateFieldValue(
      Map<String, ProjectFormFieldState<dynamic>> fields,
      String key,
      dynamic value,
    ) {
      final field = fields[key];

      if (field == null) return fields;

      if (field is ProjectFormFieldState<String>) {
        return {...fields, key: field.copyWith(value: value as String)};
      } else if (field is ProjectFormFieldState<String?>) {
        return {...fields, key: field.copyWith(value: value as String?)};
      } else if (field is ProjectFormFieldState<DateTime>) {
        return {...fields, key: field.copyWith(value: value as DateTime)};
      } else if (field is ProjectFormFieldState<DateTime?>) {
        return {...fields, key: field.copyWith(value: value as DateTime?)};
      }

      return fields;
    }

    on<SetProjectFormField>((event, emit) {
      final updatedFormFields = updateFieldValue(
        state.data.formFields,
        event.key,
        event.value,
      );
      emit(
        ProjectState(data: state.data.copyWith(formFields: updatedFormFields)),
      );
    });

    on<LoadProject>((event, emit) {
      final project = state.data.projects.firstWhere(
        (project) => project.id == event.id,
        orElse:
            () => Project(
              id: '',
              name: '',
              description: null,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              type: ProjectType.supplementMobile,
            ),
      );

      final updatedFormFields = {
        ...state.data.formFields,
        'id': ProjectFormFieldState<String>(value: project.id),
        'name': ProjectFormFieldState<String>(value: project.name),
        'description': ProjectFormFieldState<String?>(
          value: project.description,
        ),
      };

      emit(
        ProjectLoaded(data: state.data.copyWith(formFields: updatedFormFields)),
      );
    });

    on<ResetProjectForm>((event, emit) {
      emit(ProjectState(data: state.data.copyWith(resetForm: true)));
    });
  }

  ProjectValidationResult _validateProjectForm(
    Map<String, ProjectFormFieldState<dynamic>> formFields,
  ) {
    Map<String, ProjectFormFieldState<dynamic>> updatedFields = Map.from(
      formFields,
    );
    bool hasErrors = false;

    final projectName = formFields['name']?.value as String?;
    final projectDescription = formFields['description']?.value as String?;

    // Validate project name
    if (projectName == null || projectName.trim().isEmpty) {
      updatedFields['name'] = ProjectFormFieldState<String>(
        value: projectName,
        error: 'Nama projek tidak bisa kosong',
      );
      hasErrors = true;
    } else if (projectName.trim().length < 4) {
      updatedFields['name'] = ProjectFormFieldState<String>(
        value: projectName,
        error: 'Nama projek minimal 4 karakter',
      );
      hasErrors = true;
    } else {
      updatedFields['name'] = ProjectFormFieldState<String>(
        value: projectName,
        error: null,
      );
    }

    // Clear description error (if any)
    updatedFields['description'] = ProjectFormFieldState<String?>(
      value: projectDescription,
      error: null,
    );

    return ProjectValidationResult(updatedFields, hasErrors);
  }
}

class ProjectValidationResult {
  final Map<String, ProjectFormFieldState<dynamic>> updatedFields;
  final bool hasErrors;

  ProjectValidationResult(this.updatedFields, this.hasErrors);
}
