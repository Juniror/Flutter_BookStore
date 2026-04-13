import 'package:flutter/material.dart';
import '../../utils/ui_utils.dart';

/// A premium empty state widget to handle cases where no data is available.
/// Essential for providing professional feedback to the user.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.onAction,
    this.actionLabel,
  });

  /// Factory for "No Favorites" state.
  factory EmptyState.noFavorites({VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.favorite_border_rounded,
      title: 'No Favorites Yet',
      message:
          'Explore our library and save the books you love for quick access here.',
      onAction: onAction,
      actionLabel: 'Explore Books',
    );
  }

  /// Factory for "No Search Results" state.
  factory EmptyState.noSearchResults({required String query}) {
    return EmptyState(
      icon: Icons.search_off_rounded,
      title: 'No Results Found',
      message:
          'We couldn\'t find anything matching "$query". Try adjusting your keywords.',
    );
  }

  /// Factory for "Empty History" state.
  factory EmptyState.noHistory() {
    return const EmptyState(
      icon: Icons.history_rounded,
      title: 'History is Empty',
      message:
          'Start reading your first book to see your progress tracked here.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.isDarkMode ? Colors.white60 : Colors.black54,
                height: 1.5,
              ),
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 40),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    actionLabel!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
