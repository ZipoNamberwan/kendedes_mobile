import 'package:flutter/material.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/models/user.dart';

class TagListItemWidget extends StatelessWidget {
  final TagData tag;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isMultiSelectMode;
  final Project? project;
  final User? user;

  const TagListItemWidget({
    super.key,
    required this.tag,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
    this.isMultiSelectMode = false,
    this.project,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    final projectColor = tag.getColorScheme(project?.id ?? '', user?.id ?? '');

    return Card(
      elevation: isSelected ? 6 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      color:
          isSelected && !isMultiSelectMode
              ? Colors.green.shade50
              : Colors.white,
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
            border: Border(left: BorderSide(color: projectColor, width: 4)),
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
                    color:
                        isSelected
                            ? Colors.green
                            : projectColor.withValues(alpha: 0.2),
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
                        isSelected && isMultiSelectMode
                            ? Icon(Icons.check, color: Colors.white, size: 20)
                            : Text(
                              tag.sector?.key ?? '-',
                              style: TextStyle(
                                color: isSelected ? Colors.white : projectColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                          Expanded(
                            child: Text(
                              tag.businessName +
                                  (tag.businessOwner != null
                                      ? ' <${tag.businessOwner}>'
                                      : ''),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color:
                                    isSelected
                                        ? Colors.green.shade700
                                        : Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Server sync status icon
                              if (tag.showCloudIcon(project?.id ?? '')) ...[
                                Icon(
                                  tag.hasSentToServer
                                      ? Icons.cloud_done_rounded
                                      : Icons.cloud_off_rounded,
                                  size: 16,
                                  color:
                                      tag.hasSentToServer
                                          ? Colors.green.shade600
                                          : Colors.orange.shade600,
                                ),
                              ],
                              if (isSelected && !isMultiSelectMode) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Deskripsi: ${tag.description}',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isSelected
                                  ? Colors.green.shade600
                                  : Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (tag.businessAddress != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Alamat: ${tag.businessAddress}',
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
                      // const SizedBox(height: 2),
                      // Text(
                      //   'Posisi: ${tag.positionLat.toStringAsFixed(6)}, ${tag.positionLng.toStringAsFixed(6)}',
                      //   style: TextStyle(
                      //     fontSize: 12,
                      //     color:
                      //         isSelected
                      //             ? Colors.green.shade600
                      //             : Colors.grey[600],
                      //   ),
                      // ),
                      // if (tag.createdAt != null) ...[
                      //   const SizedBox(height: 2),
                      //   Text(
                      //     'Di-tagging pada: ${_formatDate(tag.createdAt ?? DateTime.now())}',
                      //     style: TextStyle(
                      //       fontSize: 11,
                      //       color:
                      //           isSelected
                      //               ? Colors.green.shade500
                      //               : Colors.grey[500],
                      //       fontStyle: FontStyle.italic,
                      //     ),
                      //   ),
                      // ],
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

  // String _formatDate(DateTime date) {
  //   return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  // }
}
