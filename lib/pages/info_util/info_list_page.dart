import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/info/info_bloc.dart';
import 'package:kendedes_mobile/bloc/info/info_event.dart';
import 'package:kendedes_mobile/bloc/info/info_state.dart';
import 'package:kendedes_mobile/models/info_util/Info.dart';
import 'package:kendedes_mobile/widgets/info_util/info_detail_dialog.dart';
import 'package:kendedes_mobile/widgets/info_util/info_item_widget.dart';

class InfoListPage extends StatefulWidget {
  const InfoListPage({super.key});

  @override
  State<InfoListPage> createState() => _InfoListPageState();
}

class _InfoListPageState extends State<InfoListPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  late InfoBloc _infoBloc;

  @override
  void initState() {
    super.initState();
    _infoBloc = context.read<InfoBloc>()..add(const Initialize());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InfoBloc, InfoState>(
      builder: (context, state) {
        if (state is InitState) {
          return Scaffold(
            body: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.deepOrange,
                    ),
                  ),
                  const Text('Memuat Informasi...'),
                ],
              ),
            ),
          );
        }
        
        final isLoadingFromServer = state.data.isLoadingFromServer;
        final isLoadingFromLocal = state.data.isLoadingFromLocal;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(130),
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
                    color: Colors.deepOrange.withValues(alpha: 0.4),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Top row
                      Row(
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Informasi',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Text(
                                      'Pengumuman & informasi terkini',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Server sync indicator in top-right corner
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child:
                                isLoadingFromServer
                                    ? Container(
                                      key: const ValueKey('syncing'),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'Sinkronisasi',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    : const SizedBox.shrink(
                                      key: ValueKey('idle'),
                                    ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Search bar
                      _buildSearchBar(
                        onChanged:
                            (v) => _infoBloc.add(SearchByKeyword(keyword: v)),
                        searchQuery: state.data.searchQuery,
                        onClear: () {
                          _searchController.clear();
                          _infoBloc.add(const SearchByKeyword(keyword: ''));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body:
              isLoadingFromLocal
                  ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.deepOrange,
                      ),
                    ),
                  )
                  : _buildList(
                    state.data.filteredInfos,
                    state.data.searchQuery,
                  ),
        );
      },
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
          hintText: 'Cari informasi...',
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

  Widget _buildList(List<Info> infos, String? searchQuery) {
    if (infos.isEmpty) return _buildEmptyState(searchQuery);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: infos.length,
      itemBuilder:
          (context, index) => InfoItemWidget(
            info: infos[index],
            onTap: () {
              _focusNode.unfocus();
              _infoBloc.add(GetInfoDetail(selectedInfo: infos[index]));
              showDialog(
                context: context,
                builder: (ctx) => InfoDetailDialog(selectedInfo: infos[index]),
              );
            },
          ),
    );
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
              Icons.notifications_none_rounded,
              size: 48,
              color: Colors.deepOrange.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery != null && searchQuery.isNotEmpty
                ? 'Informasi tidak ditemukan'
                : 'Belum ada informasi',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            searchQuery != null && searchQuery.isNotEmpty
                ? 'Coba kata kunci yang berbeda'
                : 'Informasi terbaru akan muncul di sini',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
