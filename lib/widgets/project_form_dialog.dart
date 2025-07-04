import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/project/project_bloc.dart';
import 'package:kendedes_mobile/bloc/project/project_event.dart';
import 'package:kendedes_mobile/bloc/project/project_state.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/pages/login_page.dart';
import 'package:kendedes_mobile/widgets/other_widgets/custom_snackbar.dart';

class ProjectFormDialog extends StatefulWidget {
  final Project? project;

  const ProjectFormDialog({super.key, this.project});

  @override
  State<ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<ProjectFormDialog>
    with TickerProviderStateMixin {
  late ProjectBloc _projectBloc;
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _projectBloc = context.read<ProjectBloc>();
    if (widget.project != null) {
      _projectBloc.add(LoadProject(widget.project!.id));
    } else {
      _projectBloc.add(ResetProjectForm());
    }

    nameController = TextEditingController();
    descriptionController = TextEditingController();

    // Initialize animations
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _projectBloc.add(ResetProjectForm());
    _slideController.dispose();
    _fadeController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectBloc, ProjectState>(
      listener: (context, state) {
        if (state is ProjectLoaded) {
          final formFields = state.data.formFields;
          nameController.text = formFields['name']?.value ?? '';
          descriptionController.text = formFields['description']?.value ?? '';
        } else if (state is TokenExpired) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        } else if (state is ProjectAddedSuccess ||
            state is ProjectUpdatedSuccess) {
          Navigator.pop(context);
          CustomSnackBar.showSuccess(
            context,
            message:
                'Projek berhasil ${state is ProjectAddedSuccess ? 'ditambahkan' : 'diubah'}',
          );
        }
      },
      builder: (context, state) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Compact Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepOrange.shade400,
                            Colors.orange.shade400,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              widget.project != null
                                  ? Icons.edit_rounded
                                  : Icons.add_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.project != null
                                  ? 'Ubah Projek'
                                  : 'Buat Projek',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            splashRadius: 18,
                          ),
                        ],
                      ),
                    ),

                    // Compact Form
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Project Name Field
                          const Text(
                            'Nama Projek',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: nameController,
                            onChanged:
                                (value) => _projectBloc.add(
                                  SetProjectFormField('name', value),
                                ),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Masukkan nama projek',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 15,
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.orange.shade400,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.folder_rounded,
                                color: Colors.orange.shade600,
                                size: 20,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              errorText: state.data.formFields['name']?.error,
                              errorStyle: const TextStyle(fontSize: 11),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Description field
                          const Text(
                            'Deskripsi',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: descriptionController,
                            onChanged:
                                (value) => _projectBloc.add(
                                  SetProjectFormField('description', value),
                                ),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Masukkan deskripsi projek (opsional)',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 15,
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.orange.shade400,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.description_rounded,
                                color: Colors.orange.shade600,
                                size: 20,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              errorText:
                                  state.data.formFields['description']?.error,
                              errorStyle: const TextStyle(fontSize: 11),
                            ),
                            maxLines: 2,
                            minLines: 2,
                          ),

                          const SizedBox(height: 24),

                          // Error Box
                          if (state is ProjectAddedError ||
                              state is ProjectUpdatedError)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.red.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      state is ProjectAddedError
                                          ? state.errorMessage
                                          : (state as ProjectUpdatedError)
                                              .errorMessage,
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Compact Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    backgroundColor: Colors.grey[100],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.orange.shade400,
                                        Colors.deepOrange.shade400,
                                      ],
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    onPressed:
                                        state.data.saveLoading
                                            ? null
                                            : () {
                                              if (widget.project != null) {
                                                _projectBloc.add(
                                                  UpdateProject(
                                                    project:
                                                        widget.project ??
                                                        Project(
                                                          id: '',
                                                          name:
                                                              nameController
                                                                  .text,
                                                          description:
                                                              descriptionController
                                                                  .text,
                                                          createdAt:
                                                              DateTime.now(),
                                                          updatedAt:
                                                              DateTime.now(),
                                                          type:
                                                              ProjectType
                                                                  .supplementMobile,
                                                        ),
                                                  ),
                                                );
                                              } else {
                                                _projectBloc.add(
                                                  StoreProject(),
                                                );
                                              }
                                            },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child:
                                        state.data.saveLoading
                                            ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  widget.project != null
                                                      ? 'Mengubah...'
                                                      : 'Membuat...',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            )
                                            : Text(
                                              widget.project != null
                                                  ? 'Ubah'
                                                  : 'Buat',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
