import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/browse/browse_bloc.dart';
import 'package:kendedes_mobile/bloc/browse/browse_event.dart';
import 'package:kendedes_mobile/bloc/browse/browse_state.dart';
import 'package:kendedes_mobile/models/area/sls.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/widgets/browse_widgets/business_list_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';

class BrowseSidebarWidget extends StatefulWidget {
  const BrowseSidebarWidget({super.key});

  @override
  State<BrowseSidebarWidget> createState() => _BrowseSidebarWidgetState();
}

class _BrowseSidebarWidgetState extends State<BrowseSidebarWidget> {
  late BrowseBloc _browseBloc;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _showCloseButton = true;
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _browseBloc = context.read<BrowseBloc>();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    if (offset > _lastScrollOffset && offset > 10) {
      // Scrolling down
      if (_showCloseButton) setState(() => _showCloseButton = false);
    } else {
      // Scrolling up
      if (!_showCloseButton) setState(() => _showCloseButton = true);
    }
    _lastScrollOffset = offset;
  }

  SearchFieldListItem<Sls> _buildSlsItem(Sls sls) {
    return SearchFieldListItem<Sls>(
      sls.id,
      item: sls,
      value: sls.areaName(ascending: true),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '[${sls.areaCode}]',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              sls.areaName(ascending: true),
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BrowseBloc, BrowseState>(
      listener: (context, state) {
        if ( /* state is BrowseSideBarOpened || */ state
                is SearchQueryCleared ||
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
          child: Stack(
            children: [
              Container(
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
                    // Search and Filters Section
                    Container(
                      color: Colors.grey[200],
                      padding: EdgeInsets.fromLTRB(
                        12,
                        MediaQuery.of(context).padding.top + 12,
                        12,
                        8,
                      ),
                      child: Column(
                        children: [
                          // Search Bar with close button
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  focusNode: _searchFocusNode,
                                  onChanged:
                                      (query) => _browseBloc.add(
                                        SearchBusiness(query: query),
                                      ),
                                  controller: _searchController,
                                  textAlignVertical: TextAlignVertical.center,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    hintText: 'Cari usaha...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12,
                                        right: 8,
                                      ),
                                      child: Icon(
                                        Icons.search_rounded,
                                        color: Colors.orange[400],
                                        size: 20,
                                      ),
                                    ),
                                    prefixIconConstraints: const BoxConstraints(
                                      minHeight: 40,
                                    ),
                                    suffixIcon:
                                        (state.data.searchQuery?.isNotEmpty ??
                                                false)
                                            ? GestureDetector(
                                              onTap:
                                                  () => _browseBloc.add(
                                                    SearchBusiness(reset: true),
                                                  ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 8,
                                                ),
                                                child: Icon(
                                                  Icons.cancel_rounded,
                                                  color: Colors.grey[350],
                                                  size: 18,
                                                ),
                                              ),
                                            )
                                            : null,
                                    suffixIconConstraints: const BoxConstraints(
                                      minHeight: 40,
                                    ),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.grey[200]!,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.orange[300]!,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              // close button removed, moved to bottom
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Filter Dropdown
                          SizedBox(
                            height: 36,
                            child: DropdownButtonFormField<ProjectType?>(
                              initialValue:
                                  state.data.selectedProjectTypeFilter,
                              hint: Text(
                                'Filter Tipe Usaha',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              isExpanded: true,
                              icon:
                                  state.data.selectedProjectTypeFilter != null
                                      ? GestureDetector(
                                        onTap:
                                            () => _browseBloc.add(
                                              FilterBusinessByProjectType(
                                                reset: true,
                                              ),
                                            ),
                                        child: Icon(
                                          Icons.cancel_rounded,
                                          size: 16,
                                          color: Colors.grey[400],
                                        ),
                                      )
                                      : Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 18,
                                        color: Colors.grey[500],
                                      ),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[50],
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 0,
                                ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 6,
                                  ),
                                  child: Icon(
                                    Icons.filter_list_rounded,
                                    color: Colors.orange[400],
                                    size: 16,
                                  ),
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                  minHeight: 36,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.orange[300]!,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              items:
                                  state.data.projectTypesFilterOptions.map((
                                    ProjectType projectType,
                                  ) {
                                    return DropdownMenuItem<ProjectType?>(
                                      value: projectType,
                                      child: Text(
                                        projectType.text,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
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

                          const SizedBox(height: 8),

                          // SLS Filter (SearchField)
                          SizedBox(
                            height: 36,
                            child: SearchField<Sls>(
                              selectedValue:
                                  state.data.selectedSlsFilter != null
                                      ? SearchFieldListItem<Sls>(
                                        state.data.selectedSlsFilter!.id,
                                        item: state.data.selectedSlsFilter,
                                        value: state.data.selectedSlsFilter!
                                            .areaName(ascending: true),
                                      )
                                      : null,
                              suggestions:
                                  state.data.slsFilterOptions
                                      .map(_buildSlsItem)
                                      .toList(),
                              suggestionState: Suggestion.expand,
                              onSuggestionTap: (SearchFieldListItem<Sls> item) {
                                if (item.item != null) {
                                  _browseBloc.add(
                                    FilterBusinessBySls(sls: item.item),
                                  );
                                }
                              },
                              onSearchTextChanged: (query) {
                                final q = query.trim().toLowerCase();
                                if (q.isEmpty) {
                                  return state.data.slsFilterOptions
                                      .map(_buildSlsItem)
                                      .toList();
                                }
                                return state.data.slsFilterOptions
                                    .where(
                                      (sls) =>
                                          sls.areaName().toLowerCase().contains(q) ||
                                          sls.areaCode.toLowerCase().contains(q),
                                    )
                                    .map(_buildSlsItem)
                                    .toList();
                              },
                              dynamicHeight: true,
                              maxSuggestionBoxHeight: 350,
                              searchInputDecoration: SearchInputDecoration(
                                hintText: 'Filter berdasarkan SLS',
                                searchStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                hintStyle: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.w400,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 0,
                                ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 6,
                                  ),
                                  child: Icon(
                                    Icons.location_on_rounded,
                                    color: Colors.orange[400],
                                    size: 16,
                                  ),
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                  minHeight: 36,
                                  maxWidth: 32,
                                ),
                                suffixIcon:
                                    state.data.selectedSlsFilter != null
                                        ? GestureDetector(
                                          onTap:
                                              () => _browseBloc.add(
                                                FilterBusinessBySls(
                                                  reset: true,
                                                ),
                                              ),
                                          child: Icon(
                                            Icons.cancel_rounded,
                                            size: 16,
                                            color: Colors.grey[400],
                                          ),
                                        )
                                        : Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: 18,
                                          color: Colors.grey[500],
                                        ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.orange[300]!,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              suggestionsDecoration: SuggestionDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey[200]!),
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // OLD Autocomplete code (commented out):
                          // LayoutBuilder(
                          //   builder: (context, constraints) {
                          //     return Autocomplete<Sls>(...)
                          //   },
                          // ),
                        ],
                      ),
                    ),

                    // Filtered count & divider
                    Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.storefront_rounded,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${state.data.getSortedFilteredBusinesses().length} usaha',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ' dari ${state.data.businesses.length}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                            ),
                          ),
                          const Spacer(),
                          if (state.data.isBusinessFilterActive())
                            InkWell(
                              onTap: () => _browseBloc.add(ResetAllFilter()),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.filter_alt_off_rounded,
                                      size: 12,
                                      color: Colors.orange[700],
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      'Reset',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.orange[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
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
                            controller: _scrollController,
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
              ), // Animated close button at bottom
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 12,
                left: 0,
                right: 0,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 200),
                  offset: _showCloseButton ? Offset.zero : const Offset(0, 2),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _showCloseButton ? 1.0 : 0.0,
                    child: Center(
                      child: GestureDetector(
                        onTap:
                            () => _browseBloc.add(SetBrowseSideBarOpen(false)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tutup',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
