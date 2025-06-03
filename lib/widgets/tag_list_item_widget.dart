import 'package:flutter/material.dart';
import 'package:kendedes_mobile/models/tag_data.dart';

class TagListItemWidget extends StatelessWidget {
  final TagData tag;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isMultiSelectMode;

  const TagListItemWidget({
    super.key,
    required this.tag,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
    this.isMultiSelectMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Check icon or numbered circle for multi-select mode
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? (isMultiSelectMode ? Colors.blue : Colors.orange)
                          : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child:
                      isSelected
                          ? Icon(
                            isMultiSelectMode ? Icons.check : Icons.location_on,
                            color: Colors.white,
                          )
                          : Icon(Icons.location_on, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tag.type ?? 'Tagged Location',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isSelected ? Colors.blue : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${tag.id.substring(0, 8)}...',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Position: ${tag.position.latitude.toStringAsFixed(6)}, ${tag.position.longitude.toStringAsFixed(6)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
