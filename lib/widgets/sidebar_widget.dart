import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_bloc.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_event.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_state.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/widgets/delete_tagging_confirmation_dialog.dart';
import 'package:kendedes_mobile/widgets/tag_list_item_widget.dart';

class SidebarWidget extends StatefulWidget {
  const SidebarWidget({super.key});

  @override
  State<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends State<SidebarWidget> {
  late TaggingBloc _taggingBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _taggingBloc = context.read<TaggingBloc>();
  }

  void _showDeleteConfirmationDialog(int tagCount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteTaggingConfirmationDialog(
          tagCount: tagCount,
          onConfirm: () {
            Navigator.of(context).pop();
            _taggingBloc.add(DeleteSelectedTags());
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
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
                              ? 'Select (${state.data.selectedTags.length})'
                              : 'Total (${state.data.filteredTags.length})',
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
                          : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            itemCount: state.data.filteredTags.length,
                            itemBuilder: (context, index) {
                              final tag = state.data.filteredTags[index];
                              final isSelected = state.data.selectedTags
                                  .contains(tag);

                              return TagListItemWidget(
                                tag: tag,
                                isSelected: isSelected,
                                onTap: () {
                                  if (state.data.isMultiSelectMode) {
                                    if (state.data.selectedTags.contains(tag)) {
                                      _taggingBloc.add(
                                        RemoveTagFromSelection(tag),
                                      );
                                    } else {
                                      _taggingBloc.add(AddTagToSelection(tag));
                                    }
                                  } else {
                                    _taggingBloc.add(SelectTag(tag));
                                  }
                                },
                                onLongPress: () {
                                  if (!state.data.isMultiSelectMode) {
                                    _taggingBloc.add(ToggleMultiSelectMode());
                                    _taggingBloc.add(AddTagToSelection(tag));
                                  }
                                },
                                isMultiSelectMode: state.data.isMultiSelectMode,
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (state.data.selectedTags.length == 1) {
                                // Direct delete for single tag
                                _taggingBloc.add(DeleteSelectedTags());
                              } else if (state.data.selectedTags.length > 1) {
                                // Show confirmation dialog for multiple tags
                                _showDeleteConfirmationDialog(
                                  state.data.selectedTags.length,
                                );
                              }
                            },
                            icon: const Icon(Icons.delete, size: 16),
                            label: const Text(
                              'Delete',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              minimumSize: const Size(0, 32),
                            ),
                          ),
                        ),
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
}
