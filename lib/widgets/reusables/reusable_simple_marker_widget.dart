import 'package:flutter/material.dart';
import 'package:kendedes_mobile/classes/map_config.dart';
import 'package:kendedes_mobile/models/tag_data.dart';

class ReusableSimpleMarkerWidget extends StatelessWidget {
  final TagData tagData;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isMoveMode;

  const ReusableSimpleMarkerWidget({
    super.key,
    required this.tagData,
    required this.isSelected,
    required this.onTap,
    this.isMoveMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final markerColor =
        isSelected ? Colors.green : tagData.getBrowseColorScheme();

    // If in move mode, make gray and semi-transparent
    final displayColor = isMoveMode ? Colors.grey : markerColor;

    return Opacity(
      opacity: isMoveMode ? MapConfig.moveModeOpacity : 1.0,
      child: GestureDetector(
        onTap: isMoveMode ? null : onTap, // Disable tap when in move mode
        child: Container(
          width: isSelected ? 28 : 20,
          height: isSelected ? 28 : 20,
          decoration: BoxDecoration(
            color: displayColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: isSelected ? 3 : 2),
          ),
        ),
      ),
    );
  }
}
