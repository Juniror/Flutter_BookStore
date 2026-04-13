import 'package:flutter/material.dart';
import '../../../../core/utils/ui_utils.dart';

/// A compact informational card for displaying book metadata with an icon.
class BookInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const BookInfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Icon(
              icon, 
              color: context.isDarkMode ? Colors.white38 : Colors.black38, 
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.isDarkMode ? Colors.white70 : Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.isDarkMode ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
