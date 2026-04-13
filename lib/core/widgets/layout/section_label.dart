import 'package:flutter/material.dart';
import '../../utils/ui_utils.dart';

/// A standardized label for sections within a page.
class SectionLabel extends StatelessWidget {
  final String label;
  final Color? color;

  const SectionLabel({
    super.key,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: context.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w800,
        color: color ?? Colors.blue,
        letterSpacing: 1.2,
      ),
    );
  }
}
