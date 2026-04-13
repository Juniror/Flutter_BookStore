import 'package:flutter/material.dart';
import '../../utils/ui_utils.dart';

/// A premium, gradient-styled header used across different pages.
/// Features a back button and a title/subtitle section.
class StandardPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Color>? gradientColors;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const StandardPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.gradientColors,
    this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final colors =
        gradientColors ??
        (context.isDarkMode
            ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
            : [const Color(0xFF2563EB), const Color(0xFF3B82F6)]);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Row(
        children: [
          if (Navigator.of(context).canPop())
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: onBack ?? () => Navigator.pop(context),
              ),
            ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
