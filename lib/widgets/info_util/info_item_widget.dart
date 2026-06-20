import 'package:flutter/material.dart';
import 'package:kendedes_mobile/models/info_util/Info.dart';

class InfoItemWidget extends StatelessWidget {
  final Info info;
  final VoidCallback? onTap;

  const InfoItemWidget({super.key, required this.info, this.onTap});

  @override
  Widget build(BuildContext context) {
    final typeColor = info.getTypeColor();
    final isRead = info.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isRead ? 0.04 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border(
          left: BorderSide(
            color: isRead ? Colors.grey.shade300 : typeColor,
            width: 3,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 12, 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unread dot indicator
                Padding(
                  padding: const EdgeInsets.only(top: 5, right: 8),
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRead ? Colors.transparent : typeColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type chip + date row
                      Row(
                        children: [
                          if (info.type != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                info.getTypeLabel(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isRead
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                  color: typeColor,
                                ),
                              ),
                            ),
                          const Spacer(),
                          Text(
                            info.getFormatDate(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isRead
                                  ? FontWeight.w400
                                  : FontWeight.w600,
                              color: isRead
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Title
                      Text(
                        info.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isRead
                              ? FontWeight.w500
                              : FontWeight.w700,
                          color: isRead
                              ? Colors.grey.shade800  // clear & readable
                              : Colors.grey.shade900,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Subtitle
                      if (info.subtitle != null && info.subtitle!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            info.subtitle!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isRead
                                  ? FontWeight.w400
                                  : FontWeight.w500,
                              color: isRead
                                  ? Colors.grey.shade600  // legible secondary
                                  : Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      // Tags
                      if (info.tags != null && info.tags!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: info.tags!
                                .split(',')
                                .map((tag) => tag.trim())
                                .where((tag) => tag.isNotEmpty)
                                .map(
                                  (tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Text(
                                      '#$tag',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade300,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}