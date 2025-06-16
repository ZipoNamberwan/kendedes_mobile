import 'package:flutter/material.dart';

class ZoomLevelNotificationDialog extends StatelessWidget {
  final String message;
  final VoidCallback onYes;
  final VoidCallback onCancel;

  const ZoomLevelNotificationDialog({
    super.key,
    required this.message,
    required this.onYes,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.zoom_in_map, color: Colors.orange, size: 36),
            const SizedBox(height: 12),
            Text(
              'Perbesar Peta',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.orange.shade800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onYes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Ya, Perbesar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
