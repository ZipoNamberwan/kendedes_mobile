import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/models/tag_data.dart';

class ReusableMarkerDialog extends StatelessWidget {
  final TagData tagData;
  final void Function(TagData tagData)? onMove;

  const ReusableMarkerDialog({super.key, required this.tagData, this.onMove});

  @override
  Widget build(BuildContext context) {
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
                color: tagData.getBrowseColorScheme(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white, size: 25),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Detail Tagging',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8), // Increase tap area
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 25, // Larger icon
                      ),
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
                    if (tagData.description != null)
                      _buildInfoRow('Deskripsi', tagData.description!),
                    if (tagData.buildingStatus != null)
                      _buildInfoRow(
                        'Status Bangunan',
                        tagData.buildingStatus!.text,
                      ),
                    if (tagData.sector != null)
                      _buildInfoRow('Sektor', tagData.sector!.text),
                    _buildInfoRow('Tipe Projek', tagData.project.type.text),
                    if (tagData.note != null && tagData.note!.isNotEmpty)
                      _buildInfoRow('Catatan', tagData.note!),
                    _buildInfoRow(
                      'Posisi',
                      '${tagData.positionLat.toStringAsFixed(6)}, ${tagData.positionLng.toStringAsFixed(6)}',
                    ),
                    if (tagData.sls?.hasAreaInfo ?? false)
                      _buildInfoRow(
                        'Wilayah Berdasarkan Koordinat',
                        tagData.sls!.areaInfo(),
                      ),
                    if (tagData.project.type.key == ProjectType.enumeration.key)
                      _buildInfoRow(
                        'Wilayah Berdasarkan Hasil Pencacahan',
                        tagData.originalArea ?? 'Tidak tersedia',
                      ),
                    if (tagData.buildingNumber != null)
                      _buildInfoRow('Nomor Bangunan', tagData.buildingNumber!),
                    if (tagData.user != null)
                      _buildInfoRow('Ditagging oleh', tagData.user!.firstname),
                    if (tagData.survey != null)
                      _buildInfoRow('Survei', tagData.survey!.name),
                    if (tagData.idSbr != null)
                      _buildInfoRow(
                        'ID SBR',
                        tagData.idSbr!,
                        canCopy: true,
                        context: context,
                      ),
                  ],
                ),
              ),
            ),
            if (onMove != null && tagData.canMove)
              Container(
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
                      icon: Icons.open_with,
                      label: 'Pindah',
                      color: Colors.blue,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onMove!(tagData);
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
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

  Widget _buildInfoRow(
    String label,
    String value, {
    bool canCopy = false,
    BuildContext? context,
  }) {
    assert(
      !canCopy || context != null,
      'context is required when canCopy is true',
    );
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
                if (canCopy) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      if (context != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ID SBR copied'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(2),
                      child: Icon(Icons.copy, size: 16, color: Colors.grey),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
