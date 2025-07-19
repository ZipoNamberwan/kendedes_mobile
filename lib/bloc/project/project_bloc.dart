import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/project/project_event.dart';
import 'package:kendedes_mobile/bloc/project/project_state.dart';
import 'package:kendedes_mobile/classes/api_server_handler.dart';
import 'package:kendedes_mobile/classes/repositories/auth_repository.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/project_db_repository.dart';
import 'package:kendedes_mobile/classes/repositories/local_db/tagging_db_repository.dart';
import 'package:kendedes_mobile/classes/repositories/project_repository.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:uuid/uuid.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final Uuid _uuid = const Uuid();

  ProjectBloc()
    : super(
        ProjectState(
          data: ProjectStateData(
            projects: [],
            saveLoading: false,
            initLoading: false,
            deleteLoading: false,
            isSyncing: false,
            currentUser: null,
          ),
        ),
      ) {
    on<Initialize>((event, emit) async {
      try {
        final user = AuthRepository().getUser();

        emit(
          InitializingStarted(
            data: state.data.copyWith(initLoading: true, currentUser: user),
          ),
        );

        final projects = await ProjectDbRepository().getAllProjectByUser(
          user.id,
        );

        if (projects.isEmpty) {
          await ApiServerHandler.run(
            action: () async {
              if (user.id != '') {
                final map = await ProjectRepository().getProjectsWithTags(
                  user.id,
                );
                final projects = map['projects'];
                final tags = map['tags'];

                await ProjectDbRepository().insertAll(projects);
                await TaggingDbRepository().insertAll(tags);

                emit(
                  InitializingSuccess(
                    data: state.data.copyWith(
                      projects: projects,
                      initLoading: false,
                    ),
                  ),
                );
              }
            },
            onLoginExpired: (e) {
              emit(TokenExpired(data: state.data.copyWith(initLoading: false)));
            },
            onDataProviderError: (e) {
              emit(
                ProjectLoadError(
                  errorMessage: e.message,
                  data: state.data.copyWith(initLoading: false),
                ),
              );
            },
            onOtherError: (e) {
              emit(
                ProjectLoadError(
                  errorMessage: e.toString(),
                  data: state.data.copyWith(initLoading: false),
                ),
              );
            },
          );
        } else {
          emit(
            InitializingSuccess(
              data: state.data.copyWith(projects: projects, initLoading: false),
            ),
          );
        }
      } catch (e) {
        emit(InitializingError(data: state.data, errorMessage: e.toString()));
        return;
      }
    });

    on<StoreProject>((event, emit) async {
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

      final now = DateTime.now();
      final user = AuthRepository().getUser();
      final newProject = Project(
        id: _uuid.v4(),
        name: formFields['name']?.value as String,
        description: formFields['description']?.value as String?,
        createdAt: now,
        updatedAt: now,
        type: ProjectType.supplementMobile,
        user: user,
      );

      try {
        await ApiServerHandler.run(
          action: () async {
            emit(ProjectState(data: state.data.copyWith(saveLoading: true)));
            await ProjectRepository().createProject(newProject.toJson());
            await ProjectDbRepository().insert(newProject);
            emit(
              ProjectAddedSuccess(
                data: state.data.copyWith(
                  projects: [...state.data.projects, newProject],
                  resetForm: true,
                  saveLoading: false,
                ),
              ),
            );
          },
          onLoginExpired: (e) {
            emit(TokenExpired(data: state.data.copyWith(saveLoading: false)));
          },
          onDataProviderError: (e) {
            emit(
              ProjectAddedError(
                errorMessage: e.message,
                data: state.data.copyWith(saveLoading: false),
              ),
            );
          },
          onOtherError: (e) {
            emit(
              ProjectAddedError(
                errorMessage: e.toString(),
                data: state.data.copyWith(saveLoading: false),
              ),
            );
          },
        );
      } catch (e) {
        emit(
          ProjectAddedError(
            errorMessage: e.toString(),
            data: state.data.copyWith(
              formFields: validationResult.updatedFields,
              saveLoading: false,
            ),
          ),
        );
        return;
      }
    });

    on<UpdateProject>((event, emit) async {
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

      final now = DateTime.now();
      final user = AuthRepository().getUser();
      final updatedProject = Project(
        id: event.project.id,
        name: formFields['name']?.value as String,
        description: formFields['description']?.value as String?,
        createdAt: event.project.createdAt,
        updatedAt: now,
        type: ProjectType.supplementMobile,
        user: user,
      );

      try {
        await ApiServerHandler.run(
          action: () async {
            emit(ProjectState(data: state.data.copyWith(saveLoading: true)));
            await ProjectRepository().updateProject(
              updatedProject.id,
              updatedProject.toJson(),
            );
            final updatedProjects =
                state.data.projects.map((project) {
                  return project.id == updatedProject.id
                      ? updatedProject
                      : project;
                }).toList();

            await ProjectDbRepository().insert(updatedProject);
            emit(
              ProjectUpdatedSuccess(
                data: state.data.copyWith(
                  projects: updatedProjects,
                  resetForm: true,
                  saveLoading: false,
                ),
              ),
            );
          },
          onLoginExpired: (e) {
            emit(TokenExpired(data: state.data.copyWith(saveLoading: false)));
          },
          onDataProviderError: (e) {
            emit(
              ProjectAddedError(
                errorMessage: e.message,
                data: state.data.copyWith(saveLoading: false),
              ),
            );
          },
          onOtherError: (e) {
            emit(
              ProjectAddedError(
                errorMessage: e.toString(),
                data: state.data.copyWith(saveLoading: false),
              ),
            );
          },
        );
      } catch (e) {
        emit(
          ProjectAddedError(
            errorMessage: e.toString(),
            data: state.data.copyWith(
              formFields: validationResult.updatedFields,
              saveLoading: false,
            ),
          ),
        );
        return;
      }
    });

    on<DeleteProject>((event, emit) async {
      try {
        await ApiServerHandler.run(
          action: () async {
            emit(ProjectState(data: state.data.copyWith(deleteLoading: true)));
            await ProjectRepository().deleteProject(event.id);

            await ProjectDbRepository().delete(event.id);
            await TaggingDbRepository().deleteAllByProjectId(event.id);

            emit(
              ProjectDeletedSuccess(
                data: state.data.copyWith(
                  deleteLoading: false,
                  projects:
                      state.data.projects
                          .where((project) => project.id != event.id)
                          .toList(),
                ),
              ),
            );
          },
          onLoginExpired: (e) {
            emit(TokenExpired(data: state.data.copyWith(deleteLoading: false)));
          },
          onDataProviderError: (e) {
            emit(
              ProjectDeletedError(
                errorMessage: e.message,
                data: state.data.copyWith(deleteLoading: false),
              ),
            );
          },
          onOtherError: (e) {
            emit(
              ProjectDeletedError(
                errorMessage: e.toString(),
                data: state.data.copyWith(deleteLoading: false),
              ),
            );
          },
        );
      } catch (e) {
        emit(
          ProjectDeletedError(
            errorMessage: e.toString(),
            data: state.data.copyWith(deleteLoading: false),
          ),
        );
        return;
      }
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

    on<SyncProjects>((event, emit) async {
      emit(ProjectState(data: state.data.copyWith(isSyncing: true)));

      await ApiServerHandler.run(
        action: () async {
          final user = AuthRepository().getUser();

          final map = await ProjectRepository().getProjectsWithTags(user.id);
          final projects = map['projects'];
          final tags = map['tags'];

          await ProjectDbRepository().insertAll(projects);
          await TaggingDbRepository().insertAll(tags);

          emit(
            SyncSuccess(
              data: state.data.copyWith(projects: projects, isSyncing: false),
            ),
          );
        },
        onLoginExpired: (e) {
          emit(TokenExpired(data: state.data.copyWith(isSyncing: false)));
        },
        onDataProviderError: (e) {
          emit(
            SyncFailed(
              errorMessage: e.message,
              data: state.data.copyWith(isSyncing: false),
            ),
          );
        },
        onOtherError: (e) {
          emit(
            SyncFailed(
              errorMessage: e.toString(),
              data: state.data.copyWith(isSyncing: false),
            ),
          );
        },
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
