import 'package:flutter/material.dart';
import '../../../../core/utils/ui_utils.dart';

/// A premium, interactive card for displaying a statistic with an icon and label.
/// Features gradients, depth, and glassmorphism-inspired design.
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(isDark ? 30 : 50),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {}, // Future navigation or details
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: color.withAlpha(isDark ? 40 : 30),
                width: 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDark ? const Color(0xFF1E293B) : Colors.white,
                  color.withAlpha(isDark ? 15 : 10),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Container with Glassmorphism effect
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withAlpha(isDark ? 40 : 30),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withAlpha(isDark ? 60 : 50),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 18),
                // Stat Value
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : color.withAlpha(220),
                    letterSpacing: -1,
                  ),
                ),
                // Stat Label
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black45,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
