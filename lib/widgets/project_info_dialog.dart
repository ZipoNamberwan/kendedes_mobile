import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_bloc.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_state.dart';

class ProjectInfoDialog extends StatelessWidget {
  const ProjectInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaggingBloc, TaggingState>(
      builder: (context, state) {
        final syncedCount =
            state.data.tags.where((tag) {
              return tag.hasSentToServer &&
                  tag.project.id == state.data.project.id;
            }).length;
        final unsyncedCount =
            state.data.tags.where((tag) {
              return !tag.hasSentToServer &&
                  tag.project.id == state.data.project.id;
            }).length;
        final totalTags = syncedCount + unsyncedCount;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade400,
                        Colors.orange.shade500,
                        Colors.deepOrange.shade600,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.folder_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Informasi Projek',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Project Name
                      _buildInfoSection(
                        icon: Icons.folder,
                        title: 'Nama Projek',
                        content: state.data.project.name,
                        iconColor: Colors.orange.shade600,
                      ),

                      const SizedBox(height: 6),

                      // Project Type
                      _buildInfoSection(
                        icon: Icons.category,
                        title: 'Jenis Projek',
                        content: state.data.project.type.text,
                        iconColor: Colors.blue.shade600,
                      ),

                      const SizedBox(height: 6),

                      // Project Description
                      if (state.data.project.description?.isNotEmpty ==
                          true) ...[
                        _buildInfoSection(
                          icon: Icons.description,
                          title: 'Deskripsi',
                          content: state.data.project.description!,
                          iconColor: Colors.green.shade600,
                        ),
                        const SizedBox(height: 6),
                      ],

                      // Created Date
                      _buildInfoSection(
                        icon: Icons.calendar_today,
                        title: 'Tanggal Dibuat',
                        content: _formatDate(state.data.project.createdAt),
                        iconColor: Colors.purple.shade600,
                      ),
                      const SizedBox(height: 6),

                      // Current User
                      if (state.data.currentUser != null) ...[
                        _buildInfoSection(
                          icon: Icons.person,
                          title: 'Pengguna Aktif',
                          content: state.data.currentUser!.firstname,
                          iconColor: Colors.indigo.shade600,
                        ),
                        const SizedBox(height: 6),
                      ],

                      // Statistics Section
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.analytics,
                                  size: 16,
                                  color: Colors.grey.shade700,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Statistik Tagging',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Total Tags
                            _buildStatRow(
                              'Total Tagging',
                              totalTags.toString(),
                              Colors.orange.shade600,
                              Icons.location_on,
                            ),

                            const SizedBox(height: 6),

                            // Synced Tags
                            _buildStatRow(
                              'Terupload',
                              syncedCount.toString(),
                              Colors.green.shade600,
                              Icons.cloud_done,
                            ),

                            const SizedBox(height: 6),

                            // Unsynced Tags
                            _buildStatRow(
                              'Belum Terupload',
                              unsyncedCount.toString(),
                              Colors.red.shade600,
                              Icons.cloud_off,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Additional Info
                      // Container(
                      //   padding: const EdgeInsets.all(10),
                      //   decoration: BoxDecoration(
                      //     color: Colors.blue.shade50,
                      //     borderRadius: BorderRadius.circular(6),
                      //     border: Border.all(color: Colors.blue.shade200),
                      //   ),
                      //   child: Row(
                      //     children: [
                      //       Icon(
                      //         Icons.info_outline,
                      //         color: Colors.blue.shade600,
                      //         size: 16,
                      //       ),
                      //       const SizedBox(width: 8),
                      //       Expanded(
                      //         child: Text(
                      //           'Data tagging akan disimpan secara lokal dan terupload dengan server jika dikirim.',
                      //           style: TextStyle(
                      //             color: Colors.blue.shade700,
                      //             fontSize: 13,
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 2, right: 2),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
