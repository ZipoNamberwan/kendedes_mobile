import 'package:flutter/material.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:kendedes_mobile/widgets/tag_list_item_widget.dart';

class SidebarWidget extends StatelessWidget {
  final List<TagData> tags;
  final List<TagData> selectedTags;
  final bool isSidebarOpen;
  final VoidCallback onToggleSidebar;
  final void Function(TagData tag) onTagTap;

  const SidebarWidget({
    super.key,
    required this.isSidebarOpen,
    required this.onToggleSidebar,
    required this.onTagTap,
    required this.tags,
    required this.selectedTags,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      top: 0,
      right: isSidebarOpen ? 0 : -300,
      bottom: 0,
      width: 300,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(-2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 10,
                left: 20,
                right: 10,
              ),
              decoration: const BoxDecoration(color: Colors.orange),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Tagged Locations',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: onToggleSidebar,
                  ),
                ],
              ),
            ),
            // Statistics container
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Tags:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${tags.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  tags.isEmpty
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No tags yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: tags.length,
                        itemBuilder: (context, index) {
                          final tag = tags[index];
                          final isSelected = selectedTags.contains(tag);
                          return TagListItemWidget(
                            tag: tag,
                            isSelected: isSelected,
                            onTap: () => onTagTap(tag),
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
