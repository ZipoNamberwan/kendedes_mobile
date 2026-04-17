import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/browse/browse_bloc.dart';
import 'package:kendedes_mobile/bloc/browse/browse_event.dart';
import 'package:kendedes_mobile/bloc/browse/browse_state.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/widgets/browse_widgets/business_list_item_widget.dart';
import 'package:flutter/material.dart';

class BrowseSidebarWidget extends StatefulWidget {
  const BrowseSidebarWidget({super.key});

  @override
  State<BrowseSidebarWidget> createState() => _BrowseSidebarWidgetState();
}

class _BrowseSidebarWidgetState extends State<BrowseSidebarWidget> {
  late BrowseBloc _browseBloc;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _browseBloc = context.read<BrowseBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BrowseBloc, BrowseState>(
      listener: (context, state) {
        if (state is BrowseSideBarOpened ||
            state is SearchQueryCleared ||
            state is AllFilterCleared) {
          _searchController.text = '';
        } else if (state is BrowseSideBarClosed) {
          _searchFocusNode.unfocus();
        }
      },
      builder: (context, state) {
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          top: 0,
          right: state.data.isBrowseSideBarOpen ? 0 : -300,
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
                  decoration: const BoxDecoration(color: Colors.orange),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Cari dan Filter Usaha',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed:
                            () => _browseBloc.add(SetBrowseSideBarOpen(false)),
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
                                (query) => _browseBloc.add(
                                  SearchBusiness(query: query),
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
                                            () => _browseBloc.add(
                                              SearchBusiness(reset: true),
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
                                            (projectType) => _browseBloc.add(
                                              FilterBusinessByProjectType(
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
                                          () => _browseBloc.add(
                                            FilterBusinessByProjectType(
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
                        ],
                      ),

                      // Active Filters Indicator
                      if ((state.data.searchQuery?.isNotEmpty ?? false) ||
                          state.data.selectedProjectTypeFilter != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _browseBloc.add(ResetAllFilter());
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

                // Business List
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final sortedBusinesses =
                          state.data.getSortedFilteredBusinesses();

                      if (sortedBusinesses.isEmpty) {
                        return const Center(
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
                                'Belum Ada Usaha',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        itemCount: sortedBusinesses.length,
                        itemBuilder: (context, index) {
                          final business = sortedBusinesses[index];
                          final isSelected = state.data.selectedBusinesses
                              .contains(business);

                          return BusinessListItemWidget(
                            business: business,
                            isSelected: isSelected,
                            currentLocation: state.data.currentLocation,
                            onTap: () {
                              _browseBloc.add(SelectBusiness(business));
                            },
                          );
                        },
                      );
                    },
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
