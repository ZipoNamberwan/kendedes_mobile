import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/project/project_bloc.dart';
import 'package:kendedes_mobile/bloc/project/project_event.dart';
import 'package:kendedes_mobile/bloc/project/project_state.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/pages/login_page.dart';
import 'package:kendedes_mobile/pages/tagging_page.dart';
import 'package:kendedes_mobile/widgets/other_widgets/error_scaffold.dart';
import 'package:kendedes_mobile/widgets/other_widgets/loading_scaffold.dart';
import 'package:kendedes_mobile/widgets/project_form_dialog.dart';
import 'package:kendedes_mobile/widgets/delete_project_confirmation_dialog.dart';
import 'package:kendedes_mobile/widgets/other_widgets/message_dialog.dart';
import 'package:kendedes_mobile/widgets/sync_project_dialog.dart';

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

  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

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

  Widget _appBarIconButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(icon, size: 24, color: Colors.white),
      ),
    );
  }

  void _showAppBarPopupMenu(BuildContext context, Offset position) async {
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
      ],
    );

    switch (value) {
      case 'sync':
        _sync();
        break;
    }
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
        } else if (state is SearchCleared) {
          _searchController.text = '';
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
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepOrange.shade700,
                    Colors.deepOrange.shade400,
                    Colors.orange.shade700,
                    Colors.orange.shade500,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _appBarIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Mode Tagging',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Pilih projek untuk mulai tagging',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTapDown:
                            (details) => _showAppBarPopupMenu(
                              context,
                              details.globalPosition,
                            ),
                        child: _appBarIconButton(icon: Icons.more_vert_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              // Enhanced Search Box
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(4),
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
                child: TextField(
                  focusNode: _searchFocusNode,
                  controller: _searchController,
                  onChanged:
                      (value) =>
                          _projectBloc.add(SearchProject(keyword: value)),
                  decoration: InputDecoration(
                    hintText: 'Cari projek...',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade100,
                            Colors.orange.shade50,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.search_rounded,
                        color: Colors.orange.shade600,
                        size: 20,
                      ),
                    ),
                    suffixIcon: Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (state.data.searchKeyword.isNotEmpty)
                            GestureDetector(
                              onTap: () => _projectBloc.add(ClearKeyword()),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.clear_rounded,
                                  color: Colors.red.shade600,
                                  size: 16,
                                ),
                              ),
                            ),
                          // Project count
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${state.data.filteredProjects.length} projek',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: Colors.orange.shade300,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
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
                            itemCount: state.data.filteredProjects.length,
                            itemBuilder: (context, index) {
                              final project =
                                  state.data.filteredProjects[index];
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

                                        _searchFocusNode.unfocus();
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
                                                      const SizedBox(width: 8),
                                                      // Locked tags container
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              Colors
                                                                  .blue
                                                                  .shade50,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                16,
                                                              ),
                                                          border: Border.all(
                                                            color:
                                                                Colors
                                                                    .blue
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
                                                                  .lock_rounded,
                                                              size: 14,
                                                              color:
                                                                  Colors
                                                                      .blue
                                                                      .shade600,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              '${state.data.tagCounts[project.id]?['locked'] ?? 0}',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    Colors
                                                                        .blue
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
