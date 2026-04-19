import 'package:flutter/material.dart';
import 'package:kendedes_mobile/models/tag_data.dart';

class MarkerBrowseDialog extends StatelessWidget {
  final TagData tagData;

  const MarkerBrowseDialog({super.key, required this.tagData});

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
                    _buildInfoRow('Deskripsi', tagData.description),
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
                      _buildInfoRow('Wilayah', tagData.sls!.areaInfo()),
                    if (tagData.user != null)
                      _buildInfoRow('Ditagging oleh', tagData.user!.firstname),
                    if (tagData.survey != null)
                      _buildInfoRow('Survei', tagData.survey!.name),
                  ],
                ),
              ),
            ),
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
}
