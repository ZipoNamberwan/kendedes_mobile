import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_bloc.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_event.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_state.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/widgets/delete_multiple_tag_confirmation_dialog.dart';
import 'package:kendedes_mobile/widgets/other_widgets/custom_snackbar.dart';
import 'package:kendedes_mobile/widgets/tag_list_item_widget.dart';
import 'package:kendedes_mobile/widgets/upload_selected_tags_dialog.dart';

class SidebarWidget extends StatefulWidget {
  const SidebarWidget({super.key});

  @override
  State<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends State<SidebarWidget> {
  late TaggingBloc _taggingBloc;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _taggingBloc = context.read<TaggingBloc>();
  }

  void _showDeleteConfirmationDialog(int tagCount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteMultipleTagConfirmationDialog(
          tagCount: tagCount,
          onConfirm: () {
            _taggingBloc.add(DeleteSelectedTags());
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showUploadTagsDialog(int tagCount, bool uploadAll) {
    showDialog(
      context: context,
      builder:
          (context) => UploadSelectedTagsDialog(
            tagCount: tagCount,
            onConfirm: () {
              _taggingBloc.add(UploadSelectedTags(uploadAll: uploadAll));
            },
            onCancel: () {
              Navigator.of(context).pop();
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaggingBloc, TaggingState>(
      listener: (context, state) {
        if (state is SideBarOpened ||
            state is SearchQueryCleared ||
            state is AllFilterCleared) {
          _searchController.text = '';
        } else if (state is SideBarClosed) {
          _searchFocusNode.unfocus();
        } else if (state is UploadMultipleTagsSuccess ||
            state is DeleteMultipleTagsSuccess) {
          _taggingBloc.add(SetSideBarOpen(false));
          Navigator.of(context).pop();
          final message = switch (state) {
            UploadMultipleTagsSuccess(:final successMessage) => successMessage,
            DeleteMultipleTagsSuccess(:final successMessage) => successMessage,
            _ => '',
          };

          CustomSnackBar.showSuccess(context, message: message);
        }
      },
      builder: (context, state) {
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          top: 0,
          right: state.data.isSideBarOpen ? 0 : -300,
          bottom: 0,
          width: 300,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(-2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 10,
                    bottom: 10,
                    left: 20,
                    right: 10,
                  ),
                  decoration: BoxDecoration(
                    color:
                        state.data.isMultiSelectMode
                            ? Colors.green
                            : Colors.orange,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        state.data.isMultiSelectMode
                            ? Icons.check_circle
                            : Icons.location_on,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.data.isMultiSelectMode
                              ? 'Pilih (${state.data.selectedTags.length})'
                              : 'Cari dan Filter Tagging',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (state.data.isMultiSelectMode)
                        IconButton(
                          icon: const Icon(
                            Icons.done,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed:
                              () => _taggingBloc.add(ToggleMultiSelectMode()),
                          tooltip: 'Done selecting',
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        )
                      else
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed:
                              () => _taggingBloc.add(SetSideBarOpen(false)),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                    ],
                  ),
                ),

                // Search and Filters Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Search Bar
                      Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Center(
                          child: TextField(
                            focusNode: _searchFocusNode,
                            onChanged:
                                (query) => _taggingBloc.add(
                                  SearchTagging(query: query),
                                ),
                            controller: _searchController,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              hintText: 'Cari...',
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey[500],
                                size: 18,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              suffixIcon:
                                  (state.data.searchQuery?.isNotEmpty ?? false)
                                      ? GestureDetector(
                                        onTap:
                                            () => _taggingBloc.add(
                                              SearchTagging(reset: true),
                                            ),
                                        child: Icon(
                                          Icons.clear,
                                          color: Colors.grey[500],
                                          size: 16,
                                        ),
                                      )
                                      : null,
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Filters Row
                      Row(
                        children: [
                          // Project Filter
                          Expanded(
                            child: Container(
                              height: 32,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<ProjectType?>(
                                        value:
                                            state
                                                .data
                                                .selectedProjectTypeFilter,
                                        hint: const Text(
                                          'Projek',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        isExpanded: true,
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black87,
                                        ),
                                        items:
                                            ProjectType.getProjectTypes().map((
                                              ProjectType projectType,
                                            ) {
                                              return DropdownMenuItem<
                                                ProjectType?
                                              >(
                                                value: projectType,
                                                child: SizedBox(
                                                  width: double.infinity,
                                                  child: Text(
                                                    projectType.text,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                        onChanged:
                                            (projectType) => _taggingBloc.add(
                                              FilterTaggingByProjectType(
                                                projectType: projectType,
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),
                                  if (state.data.selectedProjectTypeFilter !=
                                      null)
                                    IconButton(
                                      onPressed:
                                          () => _taggingBloc.add(
                                            FilterTaggingByProjectType(
                                              reset: true,
                                            ),
                                          ),
                                      icon: Icon(
                                        Icons.clear,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 6),

                          // Sector Filter
                          Expanded(
                            child: Container(
                              height: 32,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<Sector>(
                                        value: state.data.selectedSectorFilter,
                                        hint: const Text(
                                          'Sektor',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        isExpanded: true,
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black87,
                                        ),
                                        items:
                                            Sector.getSectors().map((
                                              Sector sector,
                                            ) {
                                              return DropdownMenuItem<Sector>(
                                                value: sector,
                                                child: SizedBox(
                                                  width: double.infinity,
                                                  child: Text(
                                                    sector.text,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                        onChanged:
                                            (sector) => _taggingBloc.add(
                                              FilterTaggingBySector(
                                                sector: sector,
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),
                                  if (state.data.selectedSectorFilter != null)
                                    IconButton(
                                      onPressed:
                                          () => _taggingBloc.add(
                                            FilterTaggingBySector(reset: true),
                                          ),
                                      icon: Icon(
                                        Icons.clear,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Active Filters Indicator
                      if ((state.data.searchQuery?.isNotEmpty ?? false) ||
                          state.data.selectedSectorFilter != null ||
                          state.data.selectedProjectTypeFilter != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              // Icon(
                              //   Icons.filter_alt,
                              //   size: 12,
                              //   color: Colors.orange[600],
                              // ),
                              // const SizedBox(width: 4),
                              // Text(
                              //   'Filter Aktif',
                              //   style: TextStyle(
                              //     fontSize: 10,
                              //     color: Colors.orange[600],
                              //     fontWeight: FontWeight.w500,
                              //   ),
                              // ),
                              // const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  _taggingBloc.add(ResetAllFilter());
                                },
                                child: Text(
                                  'Hapus Semua Filter',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange[600],
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Tags List
                Expanded(
                  child:
                      state.data.filteredTags.isEmpty
                          ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_off,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Belum Ada Tagging',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : Builder(
                            builder: (context) {
                              // Sort tags by last modified/created date (newest first)
                              final sortedTags = List<TagData>.from(
                                state.data.filteredTags,
                              )..sort((a, b) {
                                final aDate =
                                    a.updatedAt ??
                                    a.createdAt ??
                                    DateTime(1970);
                                final bDate =
                                    b.updatedAt ??
                                    b.createdAt ??
                                    DateTime(1970);
                                return bDate.compareTo(
                                  aDate,
                                ); // Descending order (newest first)
                              });

                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                itemCount: sortedTags.length,
                                itemBuilder: (context, index) {
                                  final tag = sortedTags[index];
                                  final isSelected = state.data.selectedTags
                                      .contains(tag);

                                  return TagListItemWidget(
                                    tag: tag,
                                    isSelected: isSelected,
                                    project: state.data.project,
                                    user: state.data.currentUser,
                                    onTap: () {
                                      if (state.data.isMultiSelectMode) {
                                        if (state.data.selectedTags.contains(
                                          tag,
                                        )) {
                                          _taggingBloc.add(
                                            RemoveTagFromSelection(tag),
                                          );
                                        } else {
                                          _taggingBloc.add(
                                            AddTagToSelection(tag),
                                          );
                                        }
                                      } else {
                                        _taggingBloc.add(SelectTag(tag));
                                      }
                                    },
                                    onLongPress: () {
                                      if (!state.data.isMultiSelectMode) {
                                        _taggingBloc.add(
                                          ToggleMultiSelectMode(),
                                        );
                                        _taggingBloc.add(
                                          AddTagToSelection(tag),
                                        );
                                      }
                                    },
                                    isMultiSelectMode:
                                        state.data.isMultiSelectMode,
                                  );
                                },
                              );
                            },
                          ),
                ),

                // Action buttons for selected tags
                if (state.data.selectedTags.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border(
                        top: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                () => _taggingBloc.add(ClearTagSelection()),
                            icon: const Icon(Icons.clear_all, size: 16),
                            label: const Text(
                              'Clear',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              minimumSize: const Size(0, 32),
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              // Check if any selected tags are unsynced
                              final shouldSentToServerSelectedTags = state
                                  .data
                                  .selectedTags
                                  .where((tag) {
                                    return tag.shouldSentToServer(
                                      state.data.project.id,
                                    );
                                  });

                              return ElevatedButton.icon(
                                onPressed:
                                    shouldSentToServerSelectedTags.isNotEmpty
                                        ? () {
                                          _showUploadTagsDialog(
                                            shouldSentToServerSelectedTags
                                                .length,
                                            false,
                                          );
                                        }
                                        : null,
                                icon: const Icon(Icons.cloud_upload, size: 16),
                                label: const Text(
                                  'Upload',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      shouldSentToServerSelectedTags.isNotEmpty
                                          ? Colors.blue.shade600
                                          : Colors.grey.shade400,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  minimumSize: const Size(0, 32),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final canBeDeletedSelectedTags = state
                                  .data
                                  .selectedTags
                                  .where((tag) {
                                    return tag.canBeDeleted(
                                      state.data.project.id,
                                    );
                                  });
                              return ElevatedButton.icon(
                                onPressed: () {
                                  _showDeleteConfirmationDialog(
                                    canBeDeletedSelectedTags.length,
                                  );
                                },
                                icon: const Icon(Icons.delete, size: 16),
                                label: const Text(
                                  'Hapus',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      canBeDeletedSelectedTags.isNotEmpty
                                          ? Colors.red
                                          : Colors.grey.shade400,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  minimumSize: const Size(0, 32),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  // Upload button - visible when no tags are selected
                  Builder(
                    builder: (context) {
                      final shouldSentToServerTags = state.data.tags.where((
                        tag,
                      ) {
                        return tag.shouldSentToServer(state.data.project.id);
                      });

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(color: Colors.grey[300]!, width: 1),
                          ),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed:
                                shouldSentToServerTags.isNotEmpty
                                    ? () {
                                      _showUploadTagsDialog(
                                        shouldSentToServerTags.length,
                                        true,
                                      );
                                    }
                                    : null,
                            icon: const Icon(Icons.cloud_upload, size: 16),
                            label: Text(
                              shouldSentToServerTags.isNotEmpty
                                  ? 'Upload Semua (${shouldSentToServerTags.length})'
                                  : 'Semua Telah Tersinkron',
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  shouldSentToServerTags.isNotEmpty
                                      ? Colors.blue.shade600
                                      : Colors.grey.shade400,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              minimumSize: const Size(0, 32),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
