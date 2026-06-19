import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/photo_util/photo_util_bloc.dart';
import 'package:kendedes_mobile/bloc/photo_util/photo_util_event.dart';
import 'package:kendedes_mobile/bloc/photo_util/photo_util_state.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:kendedes_mobile/models/photo_util/photo.dart';
import 'package:kendedes_mobile/pages/photo_util/photo_form_page.dart';
import 'package:kendedes_mobile/pages/photo_util/photo_result_preview.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:kendedes_mobile/widgets/other_widgets/message_dialog.dart';
import 'package:kendedes_mobile/widgets/photo_util/delete_families_dialog.dart';

class PhotoListPage extends StatefulWidget {
  const PhotoListPage({super.key});

  @override
  State<PhotoListPage> createState() => _PhotoListPageState();
}

class _PhotoListPageState extends State<PhotoListPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  late final PhotoUtilBloc _photoUtilBloc;

  @override
  void initState() {
    super.initState();
    _photoUtilBloc = context.read<PhotoUtilBloc>()..add(const Initialize());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PhotoUtilBloc, PhotoUtilState>(
      listener: (context, state) {
        if (state is DeleteSuccess) {
          Navigator.of(context).pop();
        } else if (state is DeleteFailed) {
          Navigator.of(context).pop();

          showDialog(
            context: context,
            builder:
                (context) => MessageDialog(
                  title: 'Gagal Menghapus Foto',
                  message: state.errorMessage,
                  type: MessageType.error,
                  buttonText: 'Tutup',
                ),
          );
        }
      },
      builder: (context, state) {
        final isSelectMode = state.data.isSelectMode;
        final selectedFamilies = state.data.selectedFamilies;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(140),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      isSelectMode
                          ? [
                            Colors.green.shade700,
                            Colors.green.shade500,
                            Colors.teal.shade600,
                            Colors.teal.shade400,
                          ]
                          : [
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
                    color: (isSelectMode ? Colors.green : Colors.orange)
                        .withValues(alpha: 0.4),
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
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: _buildAppBar(
                    isSelectMode: isSelectMode,
                    selectedCount: selectedFamilies.length,
                    totalCount: state.data.filteredFamilies.length,
                    searchQuery: state.data.searchQuery,
                    hasSelection: selectedFamilies.isNotEmpty,
                    isDeleteLoading: state.data.isDeleteLoading,
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton:
              isSelectMode
                  ? null
                  : FloatingActionButton.extended(
                    onPressed: () async {
                      _focusNode.unfocus();
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotoFormPage(),
                        ),
                      );
                      if (result == true) {
                        _photoUtilBloc.add(const RefreshList());
                      }
                    },
                    backgroundColor: Colors.deepOrange.shade600,
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text(
                      'Ambil Foto',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
          body: _buildGrid(
            families: state.data.filteredFamilies,
            searchQuery: state.data.searchQuery,
            isSelectMode: isSelectMode,
            selectedFamilies: selectedFamilies,
          ),
        );
      },
    );
  }

  Widget _buildAppBar({
    required bool isSelectMode,
    required int selectedCount,
    required int totalCount,
    required String? searchQuery,
    required bool hasSelection,
    required bool isDeleteLoading,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Top row — switches between normal and select mode
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder:
              (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.15),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
          child:
              isSelectMode
                  ? _buildSelectModeTopRow(
                    key: const ValueKey('select'),
                    selectedCount: selectedCount,
                    totalCount: totalCount,
                    hasSelection: hasSelection,
                    isDeleteLoading: isDeleteLoading,
                  )
                  : _buildNormalTopRow(key: const ValueKey('normal')),
        ),
        const SizedBox(height: 12),
        // Search bar always visible
        _buildSearchBar(
          onChanged: (v) {
            _photoUtilBloc.add(SearchFamily(query: v));
          },
          searchQuery: searchQuery,
          onClear: () {
            _photoUtilBloc.add(const SearchFamily(query: ''));
          },
        ),
      ],
    );
  }

  Widget _buildNormalTopRow({Key? key}) {
    return Row(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
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
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Daftar Foto',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Kelola semua foto Anda',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectModeTopRow({
    Key? key,
    required int selectedCount,
    required int totalCount,
    required bool hasSelection,
    required bool isDeleteLoading,
  }) {
    return Row(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Check/Done button to exit select mode
        GestureDetector(
          onTap: () {
            _photoUtilBloc.add(const SetSelectMode(isSelectMode: false));
          },
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
            child: const Icon(
              Icons.check_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Selected count label
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$selectedCount dipilih',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'dari $totalCount keluarga',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),
        // Select All / Deselect All button
        GestureDetector(
          onTap: () {
            _photoUtilBloc.add(const ToggleSelectAllFamilies());
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selectedCount == totalCount && totalCount > 0
                      ? Icons.deselect_rounded
                      : Icons.select_all_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  selectedCount == totalCount && totalCount > 0
                      ? 'Batal'
                      : 'Semua',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Delete button — active only when selectedFamilies is not empty
        GestureDetector(
          onTap:
              hasSelection
                  ? () {
                    showDialog(
                      context: context,
                      builder:
                          (ctx) => DeleteFamiliesDialog(
                            selectedCount: selectedCount,
                            isDeleteLoading: isDeleteLoading,
                            onDelete: () {
                              _photoUtilBloc.add(DeleteFamilies());
                            },
                          ),
                    );
                  }
                  : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color:
                  hasSelection
                      ? Colors.red.withValues(alpha: 0.85)
                      : Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    hasSelection
                        ? Colors.red.shade300
                        : Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.delete_rounded,
                  size: 16,
                  color:
                      hasSelection
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.35),
                ),
                const SizedBox(width: 4),
                Text(
                  'Hapus',
                  style: TextStyle(
                    color:
                        hasSelection
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.35),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar({
    required Function(String) onChanged,
    required String? searchQuery,
    required Function() onClear,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        onChanged: (v) => onChanged(v),
        style: const TextStyle(fontSize: 14, color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Cari foto...',
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.white.withValues(alpha: 0.8),
            size: 20,
          ),
          suffixIcon:
              searchQuery != null && searchQuery.isNotEmpty
                  ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      onClear();
                    },
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 18,
                    ),
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildGrid({
    required List<Family> families,
    required String? searchQuery,
    required bool isSelectMode,
    required List<Family> selectedFamilies,
  }) {
    if (families.isEmpty) {
      return _buildEmptyState(searchQuery);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: families.length,
      itemBuilder:
          (context, index) => _buildPhotoCard(
            families[index],
            isSelectMode: isSelectMode,
            isSelected: selectedFamilies.any((f) => f.id == families[index].id),
          ),
    );
  }

  Widget _buildPhotoCard(
    Family family, {
    required bool isSelectMode,
    required bool isSelected,
  }) {
    // Get the first photo to display as thumbnail
    final thumbnailPhoto =
        family.photos.isNotEmpty ? family.photos.first : null;

    return GestureDetector(
      onTap: () {
        if (isSelectMode) {
          _photoUtilBloc.add(SelectFamily(family: family));
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhotoResultPreview(family: family),
            ),
          );
        }
      },
      onLongPress: () {
        if (!isSelectMode) {
          _photoUtilBloc.add(const SetSelectMode(isSelectMode: true));
        }
        _photoUtilBloc.add(SelectFamily(family: family));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:
              isSelected
                  ? Border.all(color: Colors.green.shade500, width: 2.5)
                  : Border.all(color: Colors.transparent, width: 2.5),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected
                      ? Colors.green.withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.06),
              blurRadius: isSelected ? 16 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Display photo from file
                      if (thumbnailPhoto != null)
                        FutureBuilder<File>(
                          future: _getPhotoFile(thumbnailPhoto.filename),
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.data!.existsSync()) {
                              return Image.file(
                                snapshot.data!,
                                fit: BoxFit.cover,
                              );
                            }
                            return Container(
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.photo_outlined,
                                color: Colors.grey.shade400,
                                size: 40,
                              ),
                            );
                          },
                        )
                      else
                        Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.photo_outlined,
                            color: Colors.grey.shade400,
                            size: 40,
                          ),
                        ),
                      if (thumbnailPhoto != null)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              thumbnailPhoto.type.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      // Show photo count badge
                      if (family.photos.length > 1)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${family.photos.length} foto',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        family.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        family.address.isNotEmpty
                            ? family.address
                            : 'No address',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 10,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDateTime(family.createdAt),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Selection checkmark overlay
            if (isSelectMode)
              Positioned(
                top: 8,
                right: 8,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Colors.green.shade500
                            : Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child:
                      isSelected
                          ? const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          )
                          : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    // If today, show time
    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    }
    // If yesterday
    else if (difference.inDays == 1) {
      return 'Kemarin ${DateFormat('HH:mm').format(dateTime)}';
    }
    // If within a week
    else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    }
    // Otherwise show full date
    else {
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
  }

  Future<File> _getPhotoFile(String filename) async {
    // Get the path to Downloads/kdm folder
    String downloadPath;
    if (Platform.isAndroid) {
      downloadPath = '/storage/emulated/0/Download/kdm';
    } else {
      // For other platforms, use a fallback
      downloadPath = '/Download/kdm';
    }

    return File('$downloadPath/$filename');
  }

  Widget _buildEmptyState(String? searchQuery) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.photo_library_outlined,
              size: 48,
              color: Colors.orange.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery == null || searchQuery.isEmpty
                ? 'Belum ada foto'
                : 'Foto tidak ditemukan',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            searchQuery == null || searchQuery.isEmpty
                ? 'Foto yang ditambahkan akan muncul di sini'
                : 'Coba kata kunci yang berbeda',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
