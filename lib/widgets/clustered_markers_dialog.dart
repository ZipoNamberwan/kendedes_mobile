import 'package:flutter/material.dart';
import 'package:kendedes_mobile/models/tag_data.dart';

class ClusteredMarkersDialog extends StatelessWidget {
  final List<TagData> tags;
  final VoidCallback onClose;
  final void Function(TagData tag) onTagSelected;
  final List<TagData> selectedTags;

  const ClusteredMarkersDialog({
    super.key,
    required this.tags,
    required this.onClose,
    required this.onTagSelected,
    required this.selectedTags,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Multiple Tagging (${tags.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: onClose,
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  final tag = tags[index];
                  final isSelected = selectedTags.any((t) => t.id == tag.id);
                  return ListTile(
                    leading: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              isSelected ? Colors.green : Colors.grey[700],
                          radius: 16,
                          child: Text(
                            tag.sector?.key ?? '-',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Positioned(
                            right: -4,
                            bottom: -4,
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 22,
                              shadows: [
                                Shadow(
                                  color: Colors.green,
                                  blurRadius: 8,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      tag.businessName +
                          (tag.businessOwner != null
                              ? ' <${tag.businessOwner}>'
                              : ''),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.green : null,
                      ),
                    ),
                    subtitle: Text(
                      '${tag.description}\n'
                      'Posisi: ${tag.positionLat.toStringAsFixed(6)}, '
                      ', ${tag.positionLng.toStringAsFixed(6)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.green : null,
                      ),
                    ),
                    isThreeLine: true,
                    onTap: () {
                      onClose();
                      onTagSelected(tag);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
