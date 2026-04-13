import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/category_service.dart';
import '../../../core/extensions/user_extensions.dart';
import '../widgets/sections/home_header.dart';
import '../widgets/sections/home_stats_section.dart';
import '../widgets/sections/home_trending_section.dart';
import '../widgets/sections/home_recommended_section.dart';

/// The main landing page of the application.
/// Displays user stats, trending books, and personalized recommendations.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String>? _randomCategories;

  @override
  void initState() {
    super.initState();
    _pickRandomCategories();
  }

  Future<void> _pickRandomCategories() async {
    try {
      final randomCats = await CategoryService.getRandomCategories(4);
      
      if (randomCats.isNotEmpty) {
        setState(() {
          _randomCategories = randomCats;
        });
      }
    } catch (e) {
      debugPrint('Error fetching categories for recommendations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user.displayNameOrEmail;
    
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning,' : hour < 17 ? 'Good Afternoon,' : 'Good Evening,';

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: HomeHeader(userName: userName, greeting: greeting),
          ),
          SliverToBoxAdapter(
            child: HomeStatsSection(user: user),
          ),
          const SliverToBoxAdapter(
            child: HomeTrendingSection(),
          ),
          if (_randomCategories != null && _randomCategories!.isNotEmpty)
            SliverToBoxAdapter(
              child: HomeRecommendedSection(categories: _randomCategories!),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

