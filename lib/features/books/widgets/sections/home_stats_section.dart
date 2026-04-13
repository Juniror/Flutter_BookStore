import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/borrow_service.dart';
import '../../services/favorite_service.dart';
import '../../models/favorite_record.dart';
import '../../models/borrow_record.dart';
import '../cards/stat_card.dart';
import '../../../../core/utils/ui_utils.dart';

/// The stats overview section for the HomePage.
class HomeStatsSection extends StatelessWidget {
  final User? user;

  const HomeStatsSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Stats',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: context.isDarkMode ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StreamBuilder<List<FavoriteRecord>>(
                  stream: FavoriteService.getFavorites(user?.uid ?? ''),
                  builder: (context, snapshot) => StatCard(
                    title: 'Liked',
                    value: (snapshot.data?.length ?? 0).toString(),
                    icon: Icons.favorite_rounded,
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StreamBuilder<List<BorrowRecord>>(
                  stream: BorrowService.getUserBorrows(user?.uid ?? ''),
                  builder: (context, snapshot) => StatCard(
                    title: 'Borrowing',
                    value: (snapshot.data?.length ?? 0).toString(),
                    icon: Icons.auto_stories_rounded,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
