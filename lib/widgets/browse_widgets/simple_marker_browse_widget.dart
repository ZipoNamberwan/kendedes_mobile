import 'package:flutter/material.dart';
import 'package:kendedes_mobile/models/tag_data.dart';

class SimpleMarkerBrowseWidget extends StatelessWidget {
  final TagData tagData;
  final bool isSelected;
  final VoidCallback onTap;

  const SimpleMarkerBrowseWidget({
    super.key,
    required this.tagData,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Disable tap when in move mode
      child: Container(
        width: isSelected ? 28 : 20,
        height: isSelected ? 28 : 20,
        decoration: BoxDecoration(
          color: tagData.getBrowseColorScheme(),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: isSelected ? 3 : 2),
        ),
      ),
    );
  }
}
