import 'package:flutter/material.dart';

class ProjectListAppBar extends StatelessWidget implements PreferredSizeWidget {
  final void Function() onLeadingTap;
  final void Function(Offset tapPosition) onMoreTap;

  const ProjectListAppBar({
    super.key,
    required this.onLeadingTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height + 20,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepOrange.shade700,
            Colors.deepOrange.shade400,
            Colors.orange.shade700,
            Colors.orange.shade500,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 12),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _iconButton(
              icon: Icons.account_circle_rounded,
              onTap: onLeadingTap,
            ),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Kendedes Mobile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Tag Anywhere. Discover Everywhere.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTapDown: (details) => onMoreTap(details.globalPosition),
              child: _iconButton(icon: Icons.more_vert_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(icon, size: 24, color: Colors.white),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
