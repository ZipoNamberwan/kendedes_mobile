import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/kbli_util/kbli_bloc.dart';
import 'package:kendedes_mobile/bloc/kbli_util/kbli_event.dart';
import 'package:kendedes_mobile/bloc/kbli_util/kbli_state.dart';
import 'package:kendedes_mobile/models/area/regency.dart';
import 'package:kendedes_mobile/models/area/subdistrict.dart';
import 'package:kendedes_mobile/models/area/village.dart';
import 'package:kendedes_mobile/models/kbli.dart';
import 'package:kendedes_mobile/widgets/other_widgets/loading_scaffold.dart';
import 'package:kendedes_mobile/widgets/other_widgets/custom_snackbar.dart';

class TopKbliPage extends StatefulWidget {
  const TopKbliPage({super.key});

  @override
  State<TopKbliPage> createState() => _TopKbliPageState();
}

class _TopKbliPageState extends State<TopKbliPage> {
  late final KbliBloc _kbliBloc;

  @override
  void initState() {
    super.initState();
    _kbliBloc = context.read<KbliBloc>()..add(const Initialize());
  }

  Color _getCategoryColor(String category) {
    if (category.startsWith('A')) return Colors.green.shade600;
    if (category.startsWith('C')) return Colors.blue.shade600;
    if (category.startsWith('G')) return Colors.purple.shade600;
    if (category.startsWith('I')) return Colors.amber.shade700;
    if (category.startsWith('M')) return Colors.teal.shade600;
    return Colors.deepOrange.shade600;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KbliBloc, KbliState>(
      listener: (context, state) {
        if (state is KbliStatisticsError) {
          CustomSnackBar.showError(context, message: state.errorMessage);
        }
      },
      builder: (context, state) {
        if (state is Initializing) {
          return const LoadingScaffold(
            title: 'Memuat Data...',
            subtitle: 'Mohon tunggu sebentar',
          );
        }
        final data = state.data;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(76),
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
                    color: Colors.orange.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
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
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Top KBLI Wilayah',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 1),
                            Text(
                              'Peringkat Klasifikasi Usaha Terbanyak',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
          body: Column(
            children: [
              // Sticky Area Selectors Panel
              _buildFilterPanel(data),

              // Result Header & List
              Expanded(
                child: _buildBodyContent(state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBodyContent(KbliState state) {
    final data = state.data;

    if (data.isLoadingKblis) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.deepOrange,
        ),
      );
    }

    if (data.selectedSubdistrict == null) {
      return _buildEmptyState(data.selectedRegency, null);
    }

    if (state is KbliStatisticsError) {
      return _buildErrorState(state.errorMessage);
    }

    if (data.isKblisError) {
      return _buildErrorState('Gagal memuat data KBLI.');
    }

    if (data.kblis.isEmpty) {
      return _buildEmptyState(data.selectedRegency, data.selectedSubdistrict);
    }

    return _buildKbliList(data.kblis);
  }

  Widget _buildFilterPanel(KbliStateData data) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: Colors.deepOrange.shade600,
                size: 18,
              ),
              const SizedBox(width: 6),
              const Text(
                'Filter Wilayah',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Regency Selector
          _buildDropdownLabel('Kabupaten / Kota'),
          const SizedBox(height: 6),
          _buildDropdown<Regency>(
            value: data.selectedRegency,
            items: data.regencies,
            isLoading: data.isLoadingRegency,
            hint: 'Pilih Kab',
            displayText: (r) => '[${r.shortCode}] ${r.name}',
            onChanged: (value) {
              _kbliBloc.add(SelectRegency(regency: value));
            },
            onClear: () {
              _kbliBloc.add(const ClearSelectedRegency());
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Subdistrict Selector
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDropdownLabel('Kecamatan'),
                    const SizedBox(height: 6),
                    _buildDropdown<Subdistrict>(
                      value: data.selectedSubdistrict,
                      items: data.subdistricts,
                      isLoading: data.isLoadingSubdistrict,
                      hint: 'Pilih Kec',
                      displayText: (s) => '[${s.shortCode}] ${s.name}',
                      onChanged: (value) {
                        _kbliBloc.add(
                          SelectSubdistrict(subdistrict: value),
                        );
                      },
                      onClear: () {
                        _kbliBloc.add(const ClearSelectedSubdistrict());
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Village Selector
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDropdownLabel('Kelurahan / Desa'),
                    const SizedBox(height: 6),
                    _buildDropdown<Village>(
                      value: data.selectedVillage,
                      items: data.villages,
                      isLoading: data.isLoadingVillage,
                      hint: 'Pilih Des',
                      displayText: (v) => '[${v.shortCode}] ${v.name}',
                      onChanged: (value) {
                        _kbliBloc.add(
                          SelectVillage(village: value),
                        );
                      },
                      onClear: () {
                        _kbliBloc.add(const ClearSelectedVillage());
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<T> items,
    required String hint,
    required String Function(T) displayText,
    required ValueChanged<T?> onChanged,
    VoidCallback? onClear,
    bool isLoading = false,
  }) {
    final isEnabled = items.isNotEmpty && !isLoading;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isEnabled ? Colors.grey.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled ? Colors.grey.shade200 : Colors.grey.shade300,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: isLoading
                ? const Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.deepOrange,
                      ),
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<T>(
                      value: value,
                      hint: Text(
                        hint,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      ),
                      isExpanded: true,
                      icon: value != null
                          ? const SizedBox.shrink()
                          : Icon(
                              Icons.expand_more_rounded,
                              color: isEnabled
                                  ? Colors.deepOrange.shade400
                                  : Colors.grey.shade400,
                              size: 20,
                            ),
                      style: TextStyle(
                        color: isEnabled ? Colors.black87 : Colors.grey.shade500,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      onChanged: isEnabled ? onChanged : null,
                      items: items.map((T item) {
                        return DropdownMenuItem<T>(
                          value: item,
                          child: Text(
                            displayText(item),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
          if (value != null && isEnabled) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onClear,
              child: Icon(
                Icons.close_rounded,
                color: Colors.grey.shade600,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKbliList(List<Kbli> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Menampilkan Top KBLI',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Text(
                '${list.length} Klasifikasi',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepOrange.shade600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return _buildKbliCard(item, index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildKbliCard(Kbli item, int rank) {
    final catColor = _getCategoryColor(item.category ?? '');

    // Distinguish top 3 ranks visually
    Color rankBadgeColor;
    Color rankTextColor = Colors.white;
    if (rank == 1) {
      rankBadgeColor = const Color(0xFFFFD700); // Gold
      rankTextColor = Colors.black87;
    } else if (rank == 2) {
      rankBadgeColor = const Color(0xFFC0C0C0); // Silver
      rankTextColor = Colors.black87;
    } else if (rank == 3) {
      rankBadgeColor = const Color(0xFFCD7F32); // Bronze
    } else {
      rankBadgeColor = Colors.grey.shade200;
      rankTextColor = Colors.grey.shade700;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border(left: BorderSide(color: catColor, width: 5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rank badge
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: rankBadgeColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      color: rankTextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // KBLI Code Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'KBLI ${item.code}',
                    style: TextStyle(
                      color: Colors.deepOrange.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Spacer(),
                // Count Badge
                Row(
                  children: [
                    Icon(
                      Icons.storefront_rounded,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.count}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'usaha',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Description
            Text(
              item.description ?? 'Tanpa Deskripsi',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            // Category info
            Text(
              item.category ?? '',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Regency? regency, Subdistrict? subdistrict) {
    String title = 'Pilih Wilayah Terlebih Dahulu';
    String message = 'Silahkan pilih Kabupaten dan Kecamatan untuk melihat data KBLI.';

    if (regency == null) {
      title = 'Pilih Kabupaten / Kota';
      message = 'Silakan pilih Kabupaten / Kota terlebih dahulu untuk memulai.';
    } else if (subdistrict == null) {
      title = 'Pilih Kecamatan';
      message = 'Silakan pilih Kecamatan untuk melihat data KBLI di wilayah tersebut.';
    } else {
      title = 'Data Tidak Ditemukan';
      message = 'Tidak ada data KBLI yang tersedia untuk wilayah terpilih.';
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
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
                Icons.location_off_rounded,
                size: 48,
                color: Colors.orange.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gagal Memuat Data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: TextStyle(fontSize: 13, color: Colors.red.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
