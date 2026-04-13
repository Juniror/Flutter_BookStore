import 'package:flutter/material.dart';
import '../../../core/utils/ui_utils.dart';

/// A themed menu button for the profile page with support for destructive actions.
class ProfileMenuButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isLoading;

  const ProfileMenuButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(context.isDarkMode ? 40 : 10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDestructive 
                        ? Colors.red.withAlpha(context.isDarkMode ? 30 : 10)
                        : Theme.of(context).primaryColor.withAlpha(context.isDarkMode ? 30 : 10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon, 
                    size: 20,
                    color: isDestructive ? Colors.red : Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDestructive 
                        ? Colors.red 
                        : (context.isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                  ),
                ),
                const Spacer(),
                if (isLoading)
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    color: context.isDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
