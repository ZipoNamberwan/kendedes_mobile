import 'package:flutter/material.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:kendedes_mobile/widgets/tag_list_item_widget.dart';

class SidebarWidget extends StatelessWidget {
  final List<TagData> tags;
  final List<TagData> selectedTags;
  final bool isSidebarOpen;
  final VoidCallback onToggleSidebar;
  final void Function(TagData tag) onTagTap;
  final void Function(TagData tag) onTagLongPress;
  final void Function() toggleMultiSelectMode;
  final void Function() clearTagSelection;
  final void Function() deleteSelectedTags;
  final bool isMultiSelectMode;

  const SidebarWidget({
    super.key,
    required this.isSidebarOpen,
    required this.onToggleSidebar,
    required this.onTagTap,
    required this.tags,
    required this.selectedTags,
    required this.onTagLongPress,
    required this.toggleMultiSelectMode,
    required this.isMultiSelectMode,
    required this.clearTagSelection,
    required this.deleteSelectedTags,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
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
              decoration: BoxDecoration(
                color: isMultiSelectMode ? Colors.green : Colors.orange,
              ),
              child: Row(
                children: [
                  Icon(
                    isMultiSelectMode ? Icons.check_circle : Icons.location_on,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isMultiSelectMode
                          ? 'Select Tags (${selectedTags.length})'
                          : 'Total (${tags.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isMultiSelectMode)
                    IconButton(
                      icon: const Icon(Icons.done, color: Colors.white),
                      onPressed: toggleMultiSelectMode,
                      tooltip: 'Done selecting',
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: onToggleSidebar,
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
                          final isSelected =
                              isMultiSelectMode
                                  ? selectedTags.contains(tag)
                                  : selectedTags.contains(tag);

                          return TagListItemWidget(
                            tag: tag,
                            isSelected: isSelected,
                            onTap: () => onTagTap(tag),
                            onLongPress: () => onTagLongPress(tag),
                            isMultiSelectMode: isMultiSelectMode,
                          );
                        },
                      ),
            ),
            // Action buttons for selected tags
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          selectedTags.isEmpty
                              ? null
                              : () => clearTagSelection(),
                      icon: const Icon(Icons.clear_all),
                      label: const Text('Clear'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            selectedTags.isEmpty
                                ? Colors.grey[400]
                                : Colors.grey[600],
                        foregroundColor:
                            selectedTags.isEmpty
                                ? Colors.grey[600]
                                : Colors.white,
                        elevation: selectedTags.isEmpty ? 0 : 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          selectedTags.isEmpty
                              ? null
                              : () => deleteSelectedTags(),
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            selectedTags.isEmpty ? Colors.red[200] : Colors.red,
                        foregroundColor:
                            selectedTags.isEmpty
                                ? Colors.red[400]
                                : Colors.white,
                        elevation: selectedTags.isEmpty ? 0 : 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
