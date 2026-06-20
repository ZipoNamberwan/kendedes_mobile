import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/home/home_bloc.dart';
import 'package:kendedes_mobile/bloc/home/home_event.dart';
import 'package:kendedes_mobile/bloc/home/home_state.dart';
import 'package:kendedes_mobile/classes/app_config.dart';
import 'package:kendedes_mobile/models/user.dart';
import 'package:kendedes_mobile/pages/browse_page.dart';
import 'package:kendedes_mobile/pages/info_util/info_list_page.dart';
import 'package:kendedes_mobile/pages/photo_util/photo_list_page.dart';
// import 'package:kendedes_mobile/pages/project_list_page.dart';
import 'package:kendedes_mobile/pages/kbli_util/top_kbli_page.dart';
import 'package:kendedes_mobile/pages/anomaly_util/anomaly_page.dart';
import 'package:kendedes_mobile/widgets/logout_confirmation_dialog.dart';
import 'package:kendedes_mobile/widgets/other_widgets/about_app_dialog.dart';
import 'package:kendedes_mobile/widgets/profile_form_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeBloc _homeBloc;
  @override
  void initState() {
    super.initState();
    _homeBloc = context.read<HomeBloc>()..add(const Initialize());
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

  void _showAboutDialog() {
    showDialog(context: context, builder: (context) => const AboutAppDialog());
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => const LogoutConfirmationDialog(),
    );
  }

  Future<void> _showChangeProfileDialog(User user) async {
    await showDialog(
      context: context,
      builder: (context) => ProfileFormDialog(user: user),
    );
  }

  void _showUserInfo() {
    showDialog(
      context: context,
      builder:
          (context) => BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return AlertDialog(
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
                    Expanded(child: const Text('Informasi Pengguna')),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      'Email',
                      state.data.currentUser?.email ?? '-',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Nama',
                      state.data.currentUser?.firstname ?? '-',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Role',
                      state.data.currentUser?.roles.isNotEmpty == true
                          ? state.data.currentUser!.roles
                              .map((e) => e.name)
                              .join(', ')
                          : '-',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Satker',
                      state.data.currentUser?.organization?.name ?? '-',
                    ),
                  ],
                ),
                actions: [
                  // TextButton(
                  //   onPressed: () => Navigator.of(context).pop(),
                  //   child: const Text('Kembali'),
                  // ),
                  ElevatedButton(
                    onPressed: () async {
                      if (state.data.currentUser != null) {
                        await _showChangeProfileDialog(state.data.currentUser!);
                        _homeBloc.add(const RefreshUser());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Ubah Profil'),
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
              );
            },
          ),
    );
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
    }
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
      case 'help':
        _openUrl(AppConfig.helpUrl);
        break;
      case 'feedback':
        _openUrl(AppConfig.feedbackUrl);
        break;
      case 'about':
        _showAboutDialog();
        break;
      case 'logout':
        _showLogoutConfirmation();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
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
                        icon: Icons.account_circle_rounded,
                        onTap: () => _showUserInfo(),
                      ),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Kendedes Mobile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Tag Anywhere. Discover Everywhere.',
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
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Pilih menu',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Mode Jelajah untuk melihat data, atau Mode Tagging untuk mulai tagging.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildMenuCard(
                    context: context,
                    title: 'Mode Jelajah',
                    subtitle:
                        'Jelajahi usaha yang sudah ditagging, usaha SBR dan usaha lainnya',
                    icon: Icons.explore_rounded,
                    iconColor: Colors.blue,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BrowsePage()),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildMenuCard(
                    context: context,
                    title: 'Pusat Informasi',
                    subtitle:
                        'Temukan informasi terbaru, solusi permasalahan, dan pengumuman',
                    icon: Icons.info_outline_rounded,
                    iconColor: Colors.indigo,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const InfoListPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildMenuCard(
                    context: context,
                    title: 'Deteksi Anomali',
                    subtitle: 'Daftar anomali dan kejanggalan data.',
                    icon: Icons.warning_amber_rounded,
                    iconColor: Colors.red,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AnomalyPage()),
                      );
                    },
                  ),
                  // const SizedBox(height: 14),
                  // _buildMenuCard(
                  //   context: context,
                  //   title: 'Mode Tagging',
                  //   subtitle:
                  //       'Memulai tagging usaha, sinkronisasi data, dan manajemen proyek',
                  //   icon: Icons.location_on,
                  //   iconColor: Colors.deepOrange,
                  //   onTap: () {
                  //     Navigator.of(context).push(
                  //       MaterialPageRoute(
                  //         builder: (_) => const ProjectListPage(),
                  //       ),
                  //     );
                  //   },
                  // ),
                  const SizedBox(height: 14),
                  _buildMenuCard(
                    context: context,
                    title: 'Top KBLI',
                    subtitle: 'Lihat daftar KBLI terbanyak menurut wilayah.',
                    icon: Icons.bar_chart,
                    iconColor: Colors.purple,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TopKbliPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildMenuCard(
                    context: context,
                    title: 'Kamera Sensus',
                    subtitle:
                        'Gunakan fitur ini untuk mengambil foto dinding, atap dan bangunan. Foto otomatis dilengkapi nama rumah tangga, alamat, dan waktu pengambilan',
                    icon: Icons.camera_alt,
                    iconColor: Colors.green,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PhotoListPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                  Text(
                    'Kendedes Mobile',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }
}
