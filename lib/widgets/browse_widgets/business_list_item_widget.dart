import 'package:flutter/material.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:latlong2/latlong.dart';

class BusinessListItemWidget extends StatelessWidget {
  final TagData business;
  final bool isSelected;
  final VoidCallback onTap;
  final LatLng? currentLocation;

  const BusinessListItemWidget({
    super.key,
    required this.business,
    required this.isSelected,
    required this.onTap,
    this.currentLocation,
  });

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final browseColor = business.getBrowseColorScheme();
    final distance = business.distanceTo(currentLocation);
    final hasDescription =
        business.description.isNotEmpty && business.description != '-';

    return Card(
      elevation: isSelected ? 6 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? Colors.green.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.green : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient:
                isSelected
                    ? LinearGradient(
                      colors: [Colors.green.shade50, Colors.green.shade100],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                    : null,
            border: Border(
              left: BorderSide(color: browseColor, width: 4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              business.businessName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color:
                                    isSelected
                                        ? Colors.green.shade700
                                        : Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                        ],
                      ),
                      if (hasDescription) ...[
                        const SizedBox(height: 2),
                        Text(
                          business.description,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isSelected
                                    ? Colors.green.shade600
                                    : Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (business.sls?.hasAreaInfo ?? false) ...[
                        const SizedBox(height: 2),
                        Text(
                          '[${business.sls!.areaCode}]',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color:
                                isSelected
                                    ? Colors.green.shade500
                                    : Colors.grey[500],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          business.sls!.areaName(ascending: true),
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                isSelected
                                    ? Colors.green.shade500
                                    : Colors.grey[500],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            business.project.type.text,
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  isSelected
                                      ? Colors.green.shade500
                                      : Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          if (distance != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.near_me,
                              size: 12,
                              color:
                                  isSelected
                                      ? Colors.green.shade500
                                      : Colors.grey[500],
                            ),
                            const SizedBox(width: 2),
                            Text(
                              _formatDistance(distance),
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    isSelected
                                        ? Colors.green.shade500
                                        : Colors.grey[500],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}