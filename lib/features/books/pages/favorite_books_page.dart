import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/favorite_service.dart';
import '../models/favorite_record.dart';
import '../../../core/widgets/feedback/empty_state.dart';
import '../../../core/widgets/feedback/skeleton_loader.dart';
import '../../../core/utils/ui_utils.dart';

/// Displays a list of books the user has marked as favorites.
class FavoriteBooksPage extends StatelessWidget {
  const FavoriteBooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view favorite books')),
      );
    }

    return Scaffold(
      backgroundColor: context.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(context),
          StreamBuilder<List<FavoriteRecord>>(
            stream: FavoriteService.getFavorites(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SkeletonLoader.bookCard(width: double.infinity, height: 100),
                      ),
                      childCount: 4,
                    ),
                  ),
                );
              }

              final records = snapshot.data ?? [];

              if (records.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState.noFavorites(
                    onAction: () => Navigator.pop(context),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final record = records[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildFavoriteCard(context, record, user.uid),
                      );
                    },
                    childCount: records.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: context.isDarkMode 
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFFF4B2B), const Color(0xFFFF416C)], // Warmer gradient for favorites
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
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 20),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Favorite Books',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Your personal collection',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, FavoriteRecord record, String userId) {
    return Container(
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
          onTap: () {
            // Logic to navigate to book detail if needed
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(10),
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: NetworkImage('https://via.placeholder.com/50x70'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.bookTitle,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.bookAuthor,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_rounded, color: Colors.red),
                  onPressed: () async {
                    try {
                      await FavoriteService.removeFavorite(userId, record.bookId);
                      if (context.mounted) {
                        UIUtils.showSuccessSnackBar(context, 'Removed from favorites');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        UIUtils.showErrorSnackBar(context, 'Failed to remove favorite: $e');
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
