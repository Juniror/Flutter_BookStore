import 'package:flutter/material.dart';
import '../../../../core/utils/ui_utils.dart';

/// A standardized list item for displaying book summaries in lists.
class BookListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? statusText;
  final Color? statusColor;

  const BookListTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.statusText,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDarkMode ? context.theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode ? Colors.black.withAlpha(50) : Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 70,
              decoration: BoxDecoration(
                color: context.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.book, color: context.isDarkMode ? Colors.grey.shade700 : Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.isDarkMode ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.isDarkMode ? Colors.white70 : Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (statusText != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: statusColor ?? Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText!,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor ?? Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
