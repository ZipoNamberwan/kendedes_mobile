import 'package:flutter/material.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:kendedes_mobile/models/user.dart';

class MarkerDialog extends StatelessWidget {
  final TagData tagData;
  final Project project;
  final User? currentUser;
  final void Function(TagData tag) onDelete;
  final void Function(TagData tag) onMove;
  final void Function(TagData tag) onEdit;

  const MarkerDialog({
    super.key,
    required this.tagData,
    required this.onDelete,
    required this.onMove,
    required this.onEdit,
    required this.project,
    this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final headerColor = tagData.getColorScheme(
      project.id,
      currentUser?.id ?? '',
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Simple header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Detail Tagging',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            // Compact content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow('Nama Usaha', tagData.businessName),
                    if (tagData.businessOwner != null)
                      _buildInfoRow('Pemilik Usaha', tagData.businessOwner!),
                    if (tagData.businessAddress != null)
                      _buildInfoRow('Alamat', tagData.businessAddress!),
                    _buildInfoRow('Deskripsi', tagData.description),
                    _buildInfoRow(
                      'Status Bangunan',
                      tagData.buildingStatus.text,
                    ),
                    _buildInfoRow('Sektor', tagData.sector.text),
                    _buildInfoRow('Tipe Projek', tagData.project.type.text),
                    if (tagData.note != null && tagData.note!.isNotEmpty)
                      _buildInfoRow('Catatan', tagData.note!),
                    _buildInfoRow(
                      'Posisi',
                      '${tagData.positionLat.toStringAsFixed(6)}, ${tagData.positionLng.toStringAsFixed(6)}',
                    ),
                    _buildInfoRow('Ditagging oleh', tagData.user.name),
                    // if (tagData.createdAt != null)
                    //   _buildInfoRow(
                    //     'Dibuat pada',
                    //     _formatDate(tagData.createdAt!),
                    //   ),
                    // if (tagData.updatedAt != null)
                    //   _buildInfoRow(
                    //     'Diperbarui pada',
                    //     _formatDate(tagData.updatedAt!),
                    //   ),
                    // _buildInfoRow('ID', tagData.id),
                  ],
                ),
              ),
            ),
            // Simple action buttons
            tagData.project.id == project.id
                ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: Icons.edit,
                        label: 'Ubah',
                        color: Colors.green,
                        onPressed: () {
                          Navigator.of(context).pop();
                          onEdit(tagData);
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.open_with,
                        label: 'Pindah',
                        color: Colors.blue,
                        onPressed: () {
                          Navigator.of(context).pop();
                          onMove(tagData);
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.delete,
                        label: 'Hapus',
                        color: Colors.red,
                        onPressed: () {
                          Navigator.of(context).pop();
                          onDelete(tagData);
                        },
                      ),
                    ],
                  ),
                )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // String _formatDate(DateTime date) {
  //   return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  // }
}
