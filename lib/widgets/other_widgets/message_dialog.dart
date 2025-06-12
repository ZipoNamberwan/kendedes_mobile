import 'package:flutter/material.dart';

enum MessageType { error, success, info, warning }

class MessageDialog extends StatelessWidget {
  final String title;
  final String message;
  final MessageType type;
  final String? buttonText;
  final VoidCallback? onPressed;

  const MessageDialog({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(type);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      elevation: 20,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: config.backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(config.icon, color: config.iconColor, size: 32),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed ?? () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: config.buttonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: config.buttonColor.withValues(alpha: 0.3),
              ),
              child: Text(
                buttonText ?? 'OK',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _DialogConfig _getConfig(MessageType type) {
    switch (type) {
      case MessageType.error:
        return _DialogConfig(
          icon: Icons.error_outline_rounded,
          iconColor: Colors.red.shade600,
          backgroundColor: Colors.red.shade50,
          buttonColor: Colors.red.shade600,
        );
      case MessageType.success:
        return _DialogConfig(
          icon: Icons.check_circle_outline_rounded,
          iconColor: Colors.green.shade600,
          backgroundColor: Colors.green.shade50,
          buttonColor: Colors.green.shade600,
        );
      case MessageType.info:
        return _DialogConfig(
          icon: Icons.info_outline_rounded,
          iconColor: Colors.blue.shade600,
          backgroundColor: Colors.blue.shade50,
          buttonColor: Colors.blue.shade600,
        );
      case MessageType.warning:
        return _DialogConfig(
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.orange.shade600,
          backgroundColor: Colors.orange.shade50,
          buttonColor: Colors.orange.shade600,
        );
    }
  }
}

class _DialogConfig {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color buttonColor;

  _DialogConfig({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.buttonColor,
  });
}
