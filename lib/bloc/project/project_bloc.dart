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
      final projectId = formFields['id']?.value as String?;
      final projectName = formFields['name']?.value as String?;
      final projectDescription = formFields['description']?.value as String?;

      // Validate required fields
      Map<String, ProjectFormFieldState<dynamic>> updatedFormFields = Map.from(
        formFields,
      );
      bool hasErrors = false;

      if (projectName == null || projectName.trim().isEmpty) {
        updatedFormFields['name'] = ProjectFormFieldState<String>(
          value: projectName,
          error: 'Nama projek tidak bisa kosong',
        );
        hasErrors = true;
      } else if (projectName.trim().length < 4) {
        updatedFormFields['name'] = ProjectFormFieldState<String>(
          value: projectName,
          error: 'Nama projek minimal 4 karakter',
        );
        hasErrors = true;
      } else {
        updatedFormFields['name'] = ProjectFormFieldState<String>(
          value: projectName,
          error: null,
        );
      }

      updatedFormFields['description'] = ProjectFormFieldState<String?>(
        value: projectDescription,
        error: null,
      );

      if (hasErrors) {
        emit(
          ProjectState(
            data: state.data.copyWith(formFields: updatedFormFields),
          ),
        );
        return;
      }

      final now = DateTime.now();

      if (projectId == null || projectId.isEmpty) {
        // Create new project
        final newProject = Project(
          id: _uuid.v4(),
          name: projectName!.trim(),
          description: projectDescription?.trim(),
          createdAt: now,
          updatedAt: now,
        );

        emit(
          ProjectAdded(
            data: state.data.copyWith(
              projects: [...state.data.projects, newProject],
              resetForm: true, // Reset form after adding
            ),
          ),
        );
      } else {
        // Update existing project
        final updatedProjects =
            state.data.projects.map((project) {
              if (project.id == projectId) {
                return project.copyWith(
                  name: projectName!.trim(),
                  description: projectDescription?.trim(),
                  updatedAt: now,
                );
              }
              return project;
            }).toList();

        emit(
          ProjectUpdated(
            data: state.data.copyWith(
              projects: updatedProjects,
              resetForm: true, // Reset form after updating
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
}
