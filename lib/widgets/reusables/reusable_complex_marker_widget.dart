import 'package:flutter/material.dart';
import 'package:kendedes_mobile/classes/map_config.dart';
import 'package:kendedes_mobile/models/tag_data.dart';

class ReusableComplexMarkerWidget extends StatelessWidget {
  final TagData tagData;
  final bool isSelected;
  final VoidCallback onTap;
  final String? labelType;
  final bool isMoveMode;

  const ReusableComplexMarkerWidget({
    super.key,
    required this.tagData,
    required this.isSelected,
    required this.onTap,
    this.labelType,
    this.isMoveMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final markerColor =
        isSelected
            ? Colors.green
            : tagData.getBrowseColorScheme();

    // If in move mode, make gray and semi-transparent
    final displayColor = isMoveMode ? Colors.grey : markerColor;

    return Opacity(
      opacity: isMoveMode ? MapConfig.moveModeOpacity : 1.0,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 120,
                ), // Adjust width as needed
                child: Text(
                  tagData.getTagLabel(
                    labelType,
                  ), // Replace with your text property
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isMoveMode ? Colors.grey : Colors.black87,
                    backgroundColor:
                        isMoveMode
                            ? Colors.white38
                            : Colors
                                .white70, // Optional: for better readability
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: isMoveMode ? null : onTap, // Disable tap when in move mode
              child: Container(
                // duration: const Duration(milliseconds: 300),
                width: isSelected ? 40 : 30,
                height: isSelected ? 40 : 30,
                decoration: BoxDecoration(
                  color: displayColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: isSelected ? 4 : 3,
                  ),
                ),
                child: Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: isSelected ? 20 : 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
