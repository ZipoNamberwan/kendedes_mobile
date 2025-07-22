import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/polygon/polygon_bloc.dart';
import 'package:kendedes_mobile/bloc/polygon/polygon_event.dart';
import 'package:kendedes_mobile/bloc/polygon/polygon_state.dart';
import 'package:kendedes_mobile/models/area/regency.dart';
import 'package:kendedes_mobile/models/area/subdistrict.dart';
import 'package:kendedes_mobile/models/area/village.dart';
import 'package:kendedes_mobile/models/polygon.dart';
import 'package:kendedes_mobile/widgets/other_widgets/custom_snackbar.dart';

class DownloadPolygonDialog extends StatefulWidget {
  final String projectId;
  const DownloadPolygonDialog({super.key, required this.projectId});

  @override
  State<DownloadPolygonDialog> createState() => _DownloadPolygonDialogState();
}

class _DownloadPolygonDialogState extends State<DownloadPolygonDialog> {
  bool isPolygonLoading = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late final PolygonBloc _polygonBloc;

  @override
  void initState() {
    super.initState();
    _polygonBloc = context.read<PolygonBloc>()..add(Initialize());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PolygonBloc, PolygonState>(
      listener: (context, state) {
        if (state is SearchQueryCleared) {
          _searchController.clear();
          _searchFocusNode.unfocus();
        } else if (state is PolygonDownloadSuccess) {
          Navigator.of(context).pop();
        } else if (state is PolygonDownloadFailed) {
          CustomSnackBar.show(
            context,
            message: state.errorMessage,
            type: SnackBarType.error,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.purple,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white, size: 24),
            ),
            title: const Text(
              'Download Poligon',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          body:
              state.data.isInitializing
                  ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.purple,
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Memuat data area...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Mohon tunggu sebentar',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                  : Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dropdown Section
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
                              Text(
                                'Pilih Area',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Regency Dropdown
                              _buildDropdown<Regency?>(
                                label: 'Kabupaten/Kota',
                                value: state.data.selectedRegency,
                                isLoading: state.data.isLoadingRegency,
                                items: state.data.regencies,
                                displayText:
                                    (regency) =>
                                        '[${regency?.shortCode}] ${regency?.name}',
                                onChanged: (value) {
                                  _polygonBloc.add(
                                    SelectRegency(regency: value!),
                                  );
                                },
                              ),

                              const SizedBox(height: 8),

                              // Subdistrict Dropdown
                              _buildDropdown<Subdistrict?>(
                                label: 'Kecamatan',
                                value: state.data.selectedSubdistrict,
                                isLoading: state.data.isLoadingSubdistrict,
                                items: state.data.subdistricts,
                                displayText:
                                    (subdistrict) =>
                                        '[${subdistrict?.shortCode}] ${subdistrict?.name}',
                                onChanged: (value) {
                                  _polygonBloc.add(
                                    SelectSubdistrict(subdistrict: value),
                                  );
                                },
                              ),

                              const SizedBox(height: 8),

                              // Village Dropdown
                              _buildDropdown<Village?>(
                                label: 'Kelurahan/Desa',
                                value: state.data.selectedVillage,
                                isLoading: state.data.isLoadingVillage,
                                items: state.data.villages,
                                displayText:
                                    (village) =>
                                        '[${village?.shortCode}] ${village?.name}',
                                onChanged: (value) {
                                  _polygonBloc.add(
                                    SelectVillage(village: value),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Polygon List Section
                        Row(
                          children: [
                            Icon(
                              Icons.pentagon_outlined,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Daftar Poligon',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            if (state.data.filteredPolygons.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${state.data.filteredPolygons.length} poligon${state.data.searchQuery?.isNotEmpty == true ? ' ditemukan' : ''}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.purple.shade700,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Search Filter
                        if (state.data.polygons.isNotEmpty)
                          Container(
                            height: 36,
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextField(
                              focusNode: _searchFocusNode,
                              onChanged:
                                  (query) => _polygonBloc.add(
                                    SearchPolygon(query: query),
                                  ),
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Cari poligon by nama atau kode...',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey.shade400,
                                  size: 16,
                                ),
                                suffixIcon:
                                    _searchController.text.isNotEmpty
                                        ? IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                            minWidth: 32,
                                            minHeight: 32,
                                          ),
                                          icon: Icon(
                                            Icons.clear,
                                            color: Colors.grey.shade400,
                                            size: 16,
                                          ),
                                          onPressed:
                                              () => _polygonBloc.add(
                                                SearchPolygon(reset: true),
                                              ),
                                        )
                                        : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),

                        // Polygon List
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child:
                                state.data.isLoadingPolygon
                                    ? const Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            color: Colors.purple,
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'Memuat poligon...',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    : state.data.isVillageError
                                    ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            size: 64,
                                            color: Colors.red.shade400,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Gagal memuat data desa',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.red.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Terjadi kesalahan saat memuat data desa',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              if (state
                                                      .data
                                                      .selectedSubdistrict !=
                                                  null) {
                                                _polygonBloc.add(
                                                  SelectSubdistrict(
                                                    subdistrict:
                                                        state
                                                            .data
                                                            .selectedSubdistrict,
                                                  ),
                                                );
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.refresh,
                                              size: 18,
                                            ),
                                            label: const Text('Coba Lagi'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.purple,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 12,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    : state.data.isPolygonError
                                    ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            size: 64,
                                            color: Colors.red.shade400,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Gagal memuat poligon',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.red.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Terjadi kesalahan saat memuat data poligon',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              if (state.data.selectedVillage !=
                                                  null) {
                                                _polygonBloc.add(
                                                  SelectVillage(
                                                    village:
                                                        state
                                                            .data
                                                            .selectedVillage,
                                                  ),
                                                );
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.refresh,
                                              size: 18,
                                            ),
                                            label: const Text('Coba Lagi'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.purple,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 12,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    : isPolygonLoading
                                    ? const Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            color: Colors.purple,
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'Memuat poligon...',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    : state.data.filteredPolygons.isNotEmpty
                                    ? ListView.builder(
                                      padding: EdgeInsets.only(
                                        left: 12,
                                        right: 12,
                                        top: 12,
                                        bottom:
                                            state.data.selectedPolygon != null
                                                ? 70
                                                : 12,
                                      ),
                                      itemCount:
                                          state.data.filteredPolygons.length,
                                      itemBuilder: (context, index) {
                                        final polygon =
                                            state.data.filteredPolygons[index];
                                        return _buildPolygonItem(
                                          polygon.id,
                                          polygon.fullName,
                                          polygon.type.name,
                                          polygon,
                                          state.data.selectedPolygon?.id ==
                                              polygon.id,
                                        );
                                      },
                                    )
                                    : state.data.polygons.isNotEmpty
                                    ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.search_off,
                                            size: 64,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Poligon tidak ditemukan',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Coba gunakan kata kunci yang berbeda',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    : const Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.pentagon_outlined,
                                            size: 64,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'Pilih area untuk melihat poligon',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Poligon akan muncul setelah Anda memilih wilayah',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
          floatingActionButton:
              state.data.selectedPolygon != null
                  ? FloatingActionButton.extended(
                    onPressed:
                        state.data.isDownloading
                            ? null
                            : () {
                              _polygonBloc.add(
                                DownloadInstallPolygon(
                                  projectId: widget.projectId,
                                ),
                              );
                            },
                    backgroundColor:
                        state.data.isDownloading
                            ? Colors.grey
                            : _getTypeColor(
                              state.data.selectedPolygon!.type.name,
                            ),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    label:
                        state.data.isDownloading
                            ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Mengunduh...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                            : const Text(
                              'Unduh & Pasang',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  )
                  : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required bool isLoading,
    required List<T> items,
    required String Function(T) displayText,
    required ValueChanged<T?>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child:
          isLoading
              ? Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Memuat...',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
              : DropdownButtonFormField<T>(
                value: value,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  isDense: true,
                ),
                hint: Text(
                  'Pilih $label',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                items:
                    items.map((item) {
                      return DropdownMenuItem<T>(
                        value: item,
                        child: Text(
                          displayText(item),
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }).toList(),
                onChanged: onChanged,
                style: const TextStyle(color: Colors.black87, fontSize: 12),
              ),
    );
  }

  Widget _buildPolygonItem(
    String id,
    String fullName,
    String type,
    Polygon polygon,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        _polygonBloc.add(SelectPolygon(polygon: polygon));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? _getTypeColor(type).withValues(alpha: 0.1)
                  : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? _getTypeColor(type) : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _getIconBackgroundColor(type),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.pentagon_outlined,
                color: _getIconColor(type),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'ID: ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        id,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor(type),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _getIndonesianTypeName(type),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _getTypeColor(type),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Color _getIconColor(String type) {
    switch (type.toLowerCase()) {
      case 'regency':
        return Colors.red;
      case 'subdistrict':
        return Colors.blue;
      case 'village':
        return Colors.orange;
      case 'sls':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getIconBackgroundColor(String type) {
    switch (type.toLowerCase()) {
      case 'regency':
        return Colors.red.shade50;
      case 'subdistrict':
        return Colors.blue.shade50;
      case 'village':
        return Colors.orange.shade50;
      case 'sls':
        return Colors.purple.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'regency':
        return Colors.red;
      case 'subdistrict':
        return Colors.blue;
      case 'village':
        return Colors.orange;
      case 'sls':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getIndonesianTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'regency':
        return 'KABUPATEN';
      case 'subdistrict':
        return 'KECAMATAN';
      case 'village':
        return 'DESA';
      case 'sls':
        return 'SLS';
      default:
        return type.toUpperCase();
    }
  }
}
