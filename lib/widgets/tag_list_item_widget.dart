import 'package:flutter/material.dart';
import '../models/tag_data.dart';

class TagListItemWidget extends StatelessWidget {
  final TagData tag;
  final bool isSelected;
  final VoidCallback onTap;

  const TagListItemWidget({
    super.key,
    required this.tag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Colors.green.shade50 : Colors.white,
      child: Container(
        decoration:
            isSelected
                ? BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green.shade600, width: 2),
                )
                : null,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isSelected ? Colors.green.shade600 : Colors.orange,
            radius: 16,
            child: Icon(Icons.location_on, color: Colors.white, size: 12),
          ),
          title: Text(
            tag.type ?? 'Tagged Location',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.green.shade800 : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ID: ${tag.id}',
                style: TextStyle(
                  color: isSelected ? Colors.green.shade700 : null,
                ),
              ),
              Text(
                'Lat: ${tag.position.latitude.toStringAsFixed(4)}, '
                'Lng: ${tag.position.longitude.toStringAsFixed(4)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.green.shade700 : null,
                ),
              ),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
