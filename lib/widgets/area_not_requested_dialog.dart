import 'package:flutter/material.dart';

class AreaNotRequestedDialog extends StatelessWidget {
  final VoidCallback? onContinue;
  final VoidCallback? onCheckNearby;

  const AreaNotRequestedDialog({
    super.key,
    this.onContinue,
    this.onCheckNearby,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 44),
            const SizedBox(height: 14),
            const Text(
              'Belum Memuat Tagging di Sekitar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.orange,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(fontSize: 14, color: Colors.black87),
                children: [
                  TextSpan(text: 'Untuk '),
                  TextSpan(
                    text: 'menghindari duplikasi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ', sebaiknya Anda '),
                  TextSpan(
                    text: 'memuat',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' dan '),
                  TextSpan(
                    text: 'memeriksa',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' tagging di '),
                  TextSpan(
                    text: 'sekitar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        ' terlebih dahulu. Apakah akan periksa dulu atau lanjut tagging?',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      if (onContinue != null) {
                        onContinue!();
                        Navigator.of(context).pop();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Lanjut Tagging'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onCheckNearby,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Periksa Dulu'),
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
