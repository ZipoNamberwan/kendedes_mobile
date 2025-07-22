import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_bloc.dart';
import 'package:kendedes_mobile/bloc/tagging/tagging_state.dart';
import 'package:kendedes_mobile/models/polygon.dart';

class DeletePolygonDialog extends StatelessWidget {
  final Polygon polygon;
  final VoidCallback onConfirm;

  const DeletePolygonDialog({
    super.key,
    required this.polygon,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaggingBloc, TaggingState>(
      listener: (context, state) {
        if (state is PolygonDeleted) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
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
                // Header with gradient
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.shade400,
                        Colors.red.shade500,
                        Colors.red.shade600,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child:
                            state.data.isDeletingPolygon
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.data.isDeletingPolygon
                              ? 'Menghapus Poligon...'
                              : 'Hapus Poligon',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Polygon info card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.pentagon,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    polygon.fullName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.tag,
                                  size: 14,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'ID: ${polygon.id}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.category_outlined,
                                  size: 14,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Type: ${_getIndonesianTypeName(polygon.type.name)}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Confirmation text
                      Text(
                        state.data.isDeletingPolygon
                            ? 'Sedang menghapus poligon, mohon tunggu...'
                            : 'Apakah Anda yakin ingin menghapus poligon ini?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed:
                                  state.data.isDeletingPolygon
                                      ? null
                                      : () {
                                        Navigator.of(context).pop();
                                      },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                backgroundColor:
                                    state.data.isDeletingPolygon
                                        ? Colors.grey[200]
                                        : Colors.grey[100],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Batal',
                                style: TextStyle(
                                  color:
                                      state.data.isDeletingPolygon
                                          ? Colors.grey[400]
                                          : Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  state.data.isDeletingPolygon
                                      ? null
                                      : onConfirm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    state.data.isDeletingPolygon
                                        ? Colors.grey.shade400
                                        : Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child:
                                  state.data.isDeletingPolygon
                                      ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Menghapus...',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      )
                                      : const Text(
                                        'Hapus',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                            ),
                          ),
                        ],
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
