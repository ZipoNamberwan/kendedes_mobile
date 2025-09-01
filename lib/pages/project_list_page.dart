import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/project/project_bloc.dart';
import 'package:kendedes_mobile/bloc/project/project_event.dart';
import 'package:kendedes_mobile/bloc/project/project_state.dart';
import 'package:kendedes_mobile/classes/app_config.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/models/user.dart';
import 'package:kendedes_mobile/pages/login_page.dart';
import 'package:kendedes_mobile/pages/tagging_page.dart';
import 'package:kendedes_mobile/widgets/other_widgets/about_app_dialog.dart';
import 'package:kendedes_mobile/widgets/other_widgets/error_scaffold.dart';
import 'package:kendedes_mobile/widgets/other_widgets/loading_scaffold.dart';
import 'package:kendedes_mobile/widgets/project_form_dialog.dart';
import 'package:kendedes_mobile/widgets/delete_project_confirmation_dialog.dart';
import 'package:kendedes_mobile/widgets/logout_confirmation_dialog.dart';
import 'package:kendedes_mobile/widgets/other_widgets/message_dialog.dart';
import 'package:kendedes_mobile/widgets/project_list_app_bar.dart';
import 'package:kendedes_mobile/widgets/sync_project_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectListPage extends StatefulWidget {
  const ProjectListPage({super.key});

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage>
    with TickerProviderStateMixin {
  late ProjectBloc _projectBloc;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _projectBloc = context.read<ProjectBloc>()..add(Initialize());
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _showProjectForm({Project? project}) {
    showDialog(
      context: context,
      builder: (context) => ProjectFormDialog(project: project),
    );
  }

  void _confirmDelete(Project project) {
    showDialog(
      context: context,
      builder:
          (context) => DeleteProjectConfirmationDialog(
            projectName: project.name,
            onConfirm: () {
              _projectBloc.add(DeleteProject(project.id));
            },
            onCancel: () => Navigator.of(context).pop(),
          ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => LogoutConfirmationDialog(),
    );
  }

  void _showAboutDialog() {
    showDialog(context: context, builder: (context) => const AboutAppDialog());
  }

  void _showUserInfo(User user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange.shade100,
                  child: Icon(Icons.person, color: Colors.orange.shade600),
                ),
                const SizedBox(width: 12),
                const Text('Informasi Pengguna'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Nama', user.firstname),
                const SizedBox(height: 12),
                _buildInfoRow('Email', user.email),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Role',
                  user.roles.isNotEmpty
                      ? user.roles.map((e) => e.name).join(', ')
                      : '-',
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Satker', user.organization?.name ?? '-'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Kembali'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showLogoutConfirmation();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  void _showAppBarPopupMenu(
    BuildContext context,
    Offset position,
    bool noProject,
  ) async {
    final value = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        // if (noProject)
        PopupMenuItem(
          value: 'sync',
          child: Row(
            children: [
              Icon(Icons.sync, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 12),
              const Text(
                'Download Project Dari Server',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'help',
          child: Row(
            children: [
              Icon(Icons.help_rounded, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 12),
              const Text(
                'Panduan',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'feedback',
          child: Row(
            children: [
              Icon(Icons.feedback_rounded, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 12),
              const Text(
                'Saran & Masukan',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'about',
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 12),
              const Text(
                'Tentang Aplikasi',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 18, color: Colors.red[600]),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    switch (value) {
      case 'sync':
        _sync();
        break;
      case 'help':
        _openUrl(AppConfig.helpUrl);
        break;
      case 'feedback':
        _openUrl(AppConfig.feedbackUrl);
        break;
      case 'logout':
        _showLogoutConfirmation();
        break;
      case 'about':
        _showAboutDialog();
        break;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        const Text(': '),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Future<void> _openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {}
  }

  void _sync() {
    showDialog(
      context: context,
      builder:
          (context) => SyncProjectDialog(
            onConfirm: () {
              _projectBloc.add(SyncProjects());
            },
            onCancel: () {
              Navigator.of(context).pop();
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectBloc, ProjectState>(
      listener: (context, state) {
        if (state is TokenExpired) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        } else if (state is ProjectLoadError) {
          showDialog(
            context: context,
            builder:
                (context) => MessageDialog(
                  title: 'Gagal Memuat Project',
                  message: state.errorMessage,
                  type: MessageType.error,
                  buttonText: 'Tutup',
                ),
          );
        }
      },
      builder: (context, state) {
        if (state is InitializingStarted) {
          return LoadingScaffold(
            title: 'Menyiapkan halaman project...',
            subtitle: 'Mohon tunggu sebentar',
          );
        } else if (state is InitializingError) {
          return ErrorScaffold(
            title: 'Gagal Memuat Halaman Project, Mengirim Log ke Server...',
            errorMessage: state.errorMessage,
            retryButtonText: 'Coba Lagi',
            onRetry: () {
              _projectBloc.add(Initialize());
            },
          );
        }
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: ProjectListAppBar(
            onLeadingTap:
                () => _showUserInfo(
                  state.data.currentUser ??
                      User(
                        email: '',
                        firstname: '',
                        id: '',
                        organization: null,
                        roles: [],
                      ),
                ),
            onMoreTap:
                (tapPosition) => _showAppBarPopupMenu(
                  context,
                  tapPosition,
                  state.data.projects.isEmpty,
                ),
          ),
          body: Column(
            children: [
              // Enhanced Statistics Card
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade100,
                            Colors.orange.shade50,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.analytics_rounded,
                        color: Colors.orange.shade600,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Projek',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${state.data.projects.length}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Enhanced Project List
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child:
                      state.data.projects.isEmpty
                          ? SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight:
                                    MediaQuery.of(context).size.height * 0.5,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.folder_open_rounded,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Belum ada projek',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Buat projek untuk mulai tagging',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  ElevatedButton.icon(
                                    onPressed: () => _showProjectForm(),
                                    icon: const Icon(Icons.add_rounded),
                                    label: const Text('Buat Projek'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 8,
                                      shadowColor: Colors.orange.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).padding.bottom +
                                        20,
                                  ),
                                ],
                              ),
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            itemCount: state.data.projects.length,
                            itemBuilder: (context, index) {
                              final project = state.data.projects[index];
                              return AnimatedContainer(
                                duration: Duration(
                                  milliseconds: 100 + (index * 50),
                                ),
                                curve: Curves.easeOutQuart,
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.06,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.02,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Colors.grey.withValues(
                                        alpha: 0.08,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => TaggingPage(
                                                  project: project,
                                                ),
                                          ),
                                        );

                                        _projectBloc.add(RecalculateTags());
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Row(
                                          children: [
                                            Hero(
                                              tag: 'project_${project.id}',
                                              child: Container(
                                                width: 56,
                                                height: 56,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.orange.shade300,
                                                      Colors
                                                          .deepOrange
                                                          .shade400,
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.orange
                                                          .withValues(
                                                            alpha: 0.3,
                                                          ),
                                                      blurRadius: 12,
                                                      offset: const Offset(
                                                        0,
                                                        6,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: const Icon(
                                                  Icons.folder_rounded,
                                                  color: Colors.white,
                                                  size: 28,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    project.name,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                      letterSpacing: 0.3,
                                                    ),
                                                  ),
                                                  if (project
                                                          .description
                                                          ?.isNotEmpty ==
                                                      true) ...[
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      project.description ?? '',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[600],
                                                        height: 1.4,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                  const SizedBox(height: 12),
                                                  Row(
                                                    children: [
                                                      // Synced tags container
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              Colors
                                                                  .green
                                                                  .shade50,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                16,
                                                              ),
                                                          border: Border.all(
                                                            color:
                                                                Colors
                                                                    .green
                                                                    .shade200,
                                                            width: 1,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .cloud_done_rounded,
                                                              size: 14,
                                                              color:
                                                                  Colors
                                                                      .green
                                                                      .shade600,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              '${state.data.tagCounts[project.id]?['synced'] ?? 0}',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    Colors
                                                                        .green
                                                                        .shade700,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      // Unsynced tags container
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              Colors
                                                                  .orange
                                                                  .shade50,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                16,
                                                              ),
                                                          border: Border.all(
                                                            color:
                                                                Colors
                                                                    .orange
                                                                    .shade200,
                                                            width: 1,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .cloud_off_rounded,
                                                              size: 14,
                                                              color:
                                                                  Colors
                                                                      .orange
                                                                      .shade600,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              '${state.data.tagCounts[project.id]?['unsynced'] ?? 0}',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    Colors
                                                                        .orange
                                                                        .shade700,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: PopupMenuButton<String>(
                                                onSelected: (value) {
                                                  switch (value) {
                                                    case 'edit':
                                                      _showProjectForm(
                                                        project: project,
                                                      );
                                                      break;
                                                    case 'delete':
                                                      _confirmDelete(project);
                                                      break;
                                                  }
                                                },
                                                icon: Icon(
                                                  Icons.more_vert_rounded,
                                                  color: Colors.grey[600],
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                itemBuilder:
                                                    (context) => [
                                                      PopupMenuItem(
                                                        value: 'edit',
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .edit_rounded,
                                                              size: 18,
                                                              color:
                                                                  Colors
                                                                      .blue[600],
                                                            ),
                                                            const SizedBox(
                                                              width: 12,
                                                            ),
                                                            const Text(
                                                              'Edit',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 'delete',
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .delete_rounded,
                                                              size: 18,
                                                              color:
                                                                  Colors
                                                                      .red[600],
                                                            ),
                                                            const SizedBox(
                                                              width: 12,
                                                            ),
                                                            Text(
                                                              'Delete',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .red[600],
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ),
            ],
          ),
          floatingActionButton:
              state.data.projects.isNotEmpty
                  ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: FloatingActionButton.extended(
                      onPressed: () => _showProjectForm(),
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text(
                        'Buat Projek',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                  : null,
        );
      },
    );
  }
}
