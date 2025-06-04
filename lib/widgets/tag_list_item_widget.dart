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
      elevation: isSelected ? 6 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected && !isMultiSelectMode ? Colors.green.shade50 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.green : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient:
                isSelected && !isMultiSelectMode
                    ? LinearGradient(
                      colors: [Colors.green.shade50, Colors.green.shade100],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                    : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Check icon or numbered circle for multi-select mode
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green : Colors.grey[200],
                    shape: BoxShape.circle,
                    boxShadow:
                        isSelected && !isMultiSelectMode
                            ? [
                              BoxShadow(
                                color: Colors.green.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : null,
                  ),
                  child: Center(
                    child:
                        isSelected
                            ? Icon(
                              isMultiSelectMode
                                  ? Icons.check
                                  : Icons.location_on,
                              color: Colors.white,
                              size: isMultiSelectMode ? 20 : 18,
                            )
                            : Icon(Icons.location_on, color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tagged Location',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color:
                                  isSelected
                                      ? Colors.green.shade700
                                      : Colors.black,
                            ),
                          ),
                          if (isSelected && !isMultiSelectMode)
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${tag.id.substring(0, 8)}...',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isSelected
                                  ? Colors.green.shade600
                                  : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Position: ${tag.position.latitude.toStringAsFixed(6)}, ${tag.position.longitude.toStringAsFixed(6)}',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isSelected
                                  ? Colors.green.shade600
                                  : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // if (isSelected && !isMultiSelectMode)
                //   Icon(Icons.check_circle, color: Colors.green, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
