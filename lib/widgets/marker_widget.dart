import 'package:flutter/material.dart';
import 'package:kendedes_mobile/models/tag_data.dart';

class MarkerWidget extends StatelessWidget {
  final TagData tagData;
  final bool isSelected;
  final VoidCallback onTap;

  const MarkerWidget({
    super.key,
    required this.tagData,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.deepOrange,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: isSelected ? 4 : 3),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected
                      ? Colors.green.withValues(alpha: 0.6)
                      : Colors.black.withValues(alpha: 0.4),
              blurRadius: isSelected ? 10 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.location_on,
          color: Colors.white,
          size: isSelected ? 20 : 16,
        ),
      ),
    );
  }
}
