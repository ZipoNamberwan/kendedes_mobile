import 'package:flutter/material.dart';
import 'package:kendedes_mobile/models/tag_data.dart';

class MarkerWidget extends StatelessWidget {
  final TagData tagData;
  final bool isSelected;
  final VoidCallback onTap;
  final String? labelType;

  const MarkerWidget({
    super.key,
    required this.tagData,
    required this.isSelected,
    required this.onTap,
    this.labelType,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
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
                tagData.getTagLabel(labelType), // Replace with your text property
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  backgroundColor:
                      Colors.white70, // Optional: for better readability
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onTap,
            child: Container(
              // duration: const Duration(milliseconds: 300),
              width: isSelected ? 40 : 30,
              height: isSelected ? 40 : 30,
              decoration: BoxDecoration(
                color: isSelected ? Colors.green : Colors.deepOrange,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: isSelected ? 4 : 3,
                ),
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
          ),
        ],
      ),
    );
  }
}
