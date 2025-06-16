import 'package:flutter/material.dart';
import 'package:kendedes_mobile/models/project.dart';
import 'package:kendedes_mobile/models/tag_data.dart';
import 'package:kendedes_mobile/models/user.dart';

class SimpleMarkerWidget extends StatelessWidget {
  final TagData tagData;
  final bool isSelected;
  final VoidCallback onTap;
  final String? labelType;
  final User? currentUser;
  final Project? currentProject;
  const SimpleMarkerWidget({
    super.key,
    required this.tagData,
    required this.isSelected,
    required this.onTap,
    this.labelType,
    this.currentUser,
    this.currentProject,
  });

  @override
  Widget build(BuildContext context) {
    final markerColor =
        isSelected
            ? Colors.green
            : tagData.getColorScheme(
              currentProject?.id ?? '',
              currentUser?.id ?? '',
            );
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isSelected ? 28 : 20,
        height: isSelected ? 28 : 20,
        decoration: BoxDecoration(
          color: markerColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: isSelected ? 3 : 2),
        ),
      ),
    );
  }
}
